# Shared Database & Hexagonal Architecture Design

**Date**: August 28, 2025  
**Objective**: Implement hexagonal architecture with ports and adapters for both BridgeServer and next-client projects using shared database with logical separation.

## Research-Based Design Decisions

Based on extensive research of 2024-2025 microservices patterns and hexagonal architecture implementations, this design follows industry best practices while accommodating the specific constraints of our DeliCasa system.

### Key Design Principles

1. **Functional Partitioning**: Tables grouped by bounded context and service responsibility
2. **Service Ownership**: Each service owns specific tables with clear boundaries
3. **Logical Separation**: Database-level permissions and schemas for enforcement
4. **Hexagonal Architecture**: Consistent ports and adapters pattern across both services
5. **Domain Events**: Async communication between services for coordination

## Service Boundaries & Table Ownership

### BridgeServer (IoT & Hardware Service)
**Domain Focus**: IoT device management, computer vision, hardware control, stock analysis

**Owned Tables**:
- `controllers` - IoT controllers and hardware management
- `devices` - Individual IoT devices (cameras, sensors)
- `images` - Captured images from devices
- `vision_analysis` - Computer vision processing results
- `stock_analysis` - Inventory and stock level analysis
- `commands` - Device commands and control instructions
- `categories` - Product categorization for stock management

**Business Justification**: BridgeServer handles all hardware interaction and real-time device management.

### Next-Client (Business Logic Service)
**Domain Focus**: User management, orders, payments, business analytics, system monitoring

**Owned Tables**:
- `users` - User accounts and authentication
- `user_profiles` - Extended user information
- `orders` - Customer orders and order management
- `payments` - Payment processing and financial transactions
- `payment_methods` - Stored payment methods
- `sessions` - User sessions and shopping cart state
- `transactions` - Business transaction records
- `transaction_items` - Order line items
- `analytics` - Business analytics and metrics
- `audit_logs` - System audit and compliance logging
- `system_alerts` - System monitoring and alerting
- `system_metrics` - Performance and usage metrics
- `user_activity_metrics` - User behavior analytics
- `transaction_metrics` - Financial analytics
- `service_status` - Service health monitoring
- `activity_log` - User activity tracking
- `device_status_history` - Historical device status (read from BridgeServer)

**Business Justification**: Next-Client handles all customer-facing functionality and business operations.

### Shared/Cross-Service Tables
**Containers** - Accessed by both services:
- **Owner**: BridgeServer (writes container configuration)
- **Next-Client Access**: Read-only via database views
- **Use Case**: BridgeServer manages physical containers, Next-Client displays them to users

**Inventory/Products** - Hybrid ownership:
- **Owner**: BridgeServer (stock levels, physical inventory)
- **Next-Client Access**: Read for order processing, write for product catalog

## Database Access Control Strategy

### Schema-Based Separation
```sql
-- Create service-specific schemas
CREATE SCHEMA bridgeserver_private;
CREATE SCHEMA nextclient_private;
CREATE SCHEMA shared_readonly;

-- Create service-specific database roles
CREATE ROLE bridgeserver_role;
CREATE ROLE nextclient_role;

-- Grant schema permissions
GRANT ALL PRIVILEGES ON SCHEMA bridgeserver_private TO bridgeserver_role;
GRANT ALL PRIVILEGES ON SCHEMA nextclient_private TO nextclient_role;
GRANT USAGE ON SCHEMA shared_readonly TO bridgeserver_role, nextclient_role;
```

### Cross-Service Data Access
Implement **versioned read-only views** for cross-service data access:

```sql
-- Example: BridgeServer exposes container data to Next-Client
CREATE VIEW shared_readonly.containers_v1 AS 
SELECT id, name, location, status, capacity, created_at
FROM bridgeserver_private.containers
WHERE is_active = true;

GRANT SELECT ON shared_readonly.containers_v1 TO nextclient_role;
```

## Hexagonal Architecture Implementation

### Unified Port Interface Pattern

All repositories across both services will implement consistent interfaces:

```typescript
// Shared base repository pattern
interface BaseRepository<T, ID = string> {
  findById(id: ID): Promise<T | null>;
  findAll(filters?: FilterOptions): Promise<T[]>;
  save(entity: T): Promise<T>;
  update(id: ID, updates: Partial<T>): Promise<T>;
  delete(id: ID): Promise<void>;
  exists(id: ID): Promise<boolean>;
}

// Service-specific repository extensions
interface ControllerRepository extends BaseRepository<Controller> {
  findByMacAddress(macAddress: string): Promise<Controller | null>;
  findByLocation(location: string): Promise<Controller[]>;
  updateStatus(id: string, status: ControllerStatus): Promise<void>;
}
```

### Adapter Implementation Pattern

Each service implements adapters using dependency injection:

```typescript
// BridgeServer adapter
@Injectable()
export class PostgresControllerRepositoryAdapter implements ControllerRepository {
  constructor(
    private readonly db: DrizzleDB,
    private readonly logger: LoggerPort
  ) {}

  async findById(id: string): Promise<Controller | null> {
    // PostgreSQL-specific implementation
  }
}

// Next-Client adapter (same interface, different implementation)
@Injectable()
export class NextClientControllerRepositoryAdapter implements ControllerRepository {
  constructor(
    private readonly db: DrizzleDB,
    private readonly eventBus: DomainEventBus
  ) {}

  async findById(id: string): Promise<Controller | null> {
    // Business-logic aware implementation
  }
}
```

## Domain Events for Service Communication

Implement async communication using domain events:

```typescript
// Domain event definitions
interface ContainerStatusChanged extends DomainEvent {
  type: 'ContainerStatusChanged';
  containerId: string;
  oldStatus: ContainerStatus;
  newStatus: ContainerStatus;
  timestamp: Date;
}

// BridgeServer publishes events
class ContainerService {
  async updateContainerStatus(id: string, status: ContainerStatus) {
    const container = await this.containerRepository.updateStatus(id, status);
    
    await this.eventBus.publish(new ContainerStatusChanged({
      containerId: id,
      oldStatus: container.previousStatus,
      newStatus: status,
      timestamp: new Date()
    }));
  }
}

// Next-Client subscribes to events
@EventHandler(ContainerStatusChanged)
class ContainerStatusEventHandler {
  async handle(event: ContainerStatusChanged) {
    // Update business logic, notify users, update analytics, etc.
  }
}
```

## Directory Structure Standardization

Both projects will follow the same hexagonal architecture structure:

```
src/
├── domain/
│   ├── entities/           # Domain entities
│   ├── ports/             # Interface definitions
│   ├── services/          # Domain services
│   ├── events/            # Domain events
│   └── value-objects/     # Value objects
├── application/
│   ├── usecases/          # Application use cases
│   ├── dtos/              # Data transfer objects
│   ├── handlers/          # Event handlers
│   └── services/          # Application services
├── infrastructure/
│   ├── adapters/          # Port implementations
│   │   ├── repositories/  # Database adapters
│   │   ├── messaging/     # Event bus adapters
│   │   ├── external/      # External API adapters
│   │   └── storage/       # File/image storage adapters
│   ├── persistence/       # Database configurations
│   ├── messaging/         # Event infrastructure
│   └── config/            # Configuration
└── interfaces/
    ├── http/              # REST controllers
    ├── websocket/         # WebSocket handlers
    ├── graphql/           # GraphQL resolvers (if applicable)
    └── cli/               # CLI commands
```

## Implementation Benefits

### 1. **Maintainability**
- Clear service boundaries prevent cross-service coupling
- Consistent architecture reduces cognitive load
- Unified patterns enable code sharing and team mobility

### 2. **Scalability**
- Logical separation allows independent service scaling
- Database permissions prevent accidental cross-service interference
- Event-driven communication enables async processing

### 3. **Testability**
- Ports enable easy mocking and testing
- Domain logic is isolated from infrastructure
- Event handlers can be tested independently

### 4. **Flexibility**
- Easy to migrate to separate databases later
- External API integrations follow same adapter pattern
- Service boundaries can evolve without breaking other services

## Migration Strategy

### Phase 1: Standardize Hexagonal Architecture
1. Refactor BridgeServer to consistent hexagonal pattern
2. Refactor Next-Client to match BridgeServer architecture
3. Create shared TypeScript interfaces for common patterns

### Phase 2: Implement Database Separation
1. Create database schemas and roles
2. Migrate table ownership to appropriate services
3. Implement cross-service read-only views

### Phase 3: Add Domain Events
1. Implement event bus infrastructure
2. Add domain event publishing to services
3. Create event handlers for cross-service communication

### Phase 4: Validation & Testing
1. Comprehensive integration testing
2. Performance testing with separated access patterns
3. Security testing of database permissions

## Success Metrics

- **Code Quality**: Consistent architecture patterns across both services
- **Performance**: No degradation in database query performance
- **Security**: Proper isolation with database-level access controls
- **Maintainability**: Reduced coupling between services
- **Testability**: Improved test coverage and isolation

---

**Next Steps**: Begin implementation with Phase 1 - Standardizing hexagonal architecture across both projects.