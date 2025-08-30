# DeliCasa Shared Types

This package provides shared TypeScript types and interfaces for implementing hexagonal architecture with ports and adapters across the DeliCasa BridgeServer and next-client projects.

## Overview

The shared types package enforces consistent architecture patterns and domain modeling across both services while supporting a shared database with logical separation strategy.

## Architecture Pattern

This package implements:
- **Hexagonal Architecture** (Ports and Adapters)
- **Domain-Driven Design** principles
- **Shared Database with Logical Separation**
- **Event-Driven Communication** between services

## Package Structure

```
shared/
├── types/
│   ├── base-repository.ts      # Base repository interfaces
│   └── domain-entities.ts      # Domain entities and value objects
├── ports/
│   ├── repository-ports.ts     # Repository port contracts
│   └── service-ports.ts        # Service port contracts
├── index.ts                    # Main exports
├── package.json
├── tsconfig.json
└── README.md
```

## Installation

Since this is a local package, install it using file path:

```bash
# In BridgeServer
npm install file:../shared

# In next-client
npm install file:../shared
```

Or add to package.json:

```json
{
  "dependencies": {
    "@delicasa/shared-types": "file:../shared"
  }
}
```

## Usage

### Basic Imports

```typescript
import {
  // Base repository interfaces
  BaseRepository,
  FilterOptions,
  PaginatedResponse,
  
  // Domain entities
  User,
  Controller,
  Device,
  Container,
  Order,
  
  // Repository ports
  UserRepositoryPort,
  ControllerRepositoryPort,
  DeviceRepositoryPort,
  
  // Service ports
  UserManagementServicePort,
  DeviceManagementServicePort,
  
  // Enums
  UserRole,
  DeviceType,
  ControllerStatus,
  
  // Utilities
  generateEntityId,
  createDomainEvent,
  success,
  failure
} from '@delicasa/shared-types';
```

### Implementing Repository Adapters

```typescript
import { ControllerRepositoryPort, Controller, ControllerStatus } from '@delicasa/shared-types';

export class PostgresControllerRepositoryAdapter implements ControllerRepositoryPort {
  constructor(private db: DatabaseConnection) {}

  async findById(id: string): Promise<Controller | null> {
    // Implementation specific to your database adapter
    const result = await this.db.query('SELECT * FROM controllers WHERE id = $1', [id]);
    return result.rows[0] ? this.mapToController(result.rows[0]) : null;
  }

  async findByMacAddress(macAddress: string): Promise<Controller | null> {
    // Implementation
  }

  // ... implement all other required methods
}
```

### Implementing Application Services

```typescript
import { 
  ControllerManagementServicePort,
  RegisterControllerCommand,
  ControllerRepositoryPort,
  Result,
  success,
  failure
} from '@delicasa/shared-types';

export class ControllerManagementService implements ControllerManagementServicePort {
  constructor(private controllerRepo: ControllerRepositoryPort) {}

  async registerController(command: RegisterControllerCommand): Promise<Result<ControllerRegistrationResult>> {
    try {
      // Validate command
      if (!command.macAddress) {
        return failure(new Error('MAC address is required'));
      }

      // Check if controller already exists
      const existing = await this.controllerRepo.findByMacAddress(command.macAddress);
      if (existing) {
        return failure(new Error('Controller already registered'));
      }

      // Create and save controller
      const controller = this.createController(command);
      const saved = await this.controllerRepo.save(controller);

      return success({
        controller: saved,
        token: generateAuthToken(),
        configurationEndpoint: `${API_BASE}/controllers/${saved.id}/config`
      });
    } catch (error) {
      return failure(error as Error);
    }
  }

  // ... implement other service methods
}
```

### Using Domain Events

```typescript
import { 
  createDomainEvent,
  DOMAIN_EVENT_TYPES,
  ControllerStatusChanged,
  EventBusServicePort
} from '@delicasa/shared-types';

export class ControllerService {
  constructor(
    private controllerRepo: ControllerRepositoryPort,
    private eventBus: EventBusServicePort
  ) {}

  async updateStatus(controllerId: string, newStatus: ControllerStatus): Promise<void> {
    const controller = await this.controllerRepo.findById(controllerId);
    if (!controller) throw new Error('Controller not found');

    const previousStatus = controller.status;
    await this.controllerRepo.updateStatus(controllerId, newStatus);

    // Publish domain event
    const event = createDomainEvent(
      DOMAIN_EVENT_TYPES.CONTROLLER_STATUS_CHANGED,
      controllerId,
      'Controller',
      {
        controllerId,
        previousStatus,
        newStatus,
        reason: 'Manual status update'
      }
    );

    await this.eventBus.publish(event);
  }
}
```

## Service Boundaries

The package defines clear service boundaries based on domain responsibilities:

### BridgeServer Domain
- **IoT Hardware Management**: Controllers, devices, cameras
- **Computer Vision**: Image processing, object detection
- **Hardware Control**: Device commands, status monitoring

**Owned Tables**: `controllers`, `devices`, `images`, `vision_analysis`, `stock_analysis`, `commands`, `categories`

### Next-Client Domain
- **User Management**: Authentication, profiles, preferences
- **Business Logic**: Orders, payments, shopping carts
- **Analytics**: Business metrics, user activity, system monitoring

**Owned Tables**: `users`, `orders`, `payments`, `sessions`, `analytics`, `audit_logs`, etc.

### Shared Tables
- **Containers**: Owned by BridgeServer, read access for Next-Client
- **Products/Inventory**: Hybrid ownership with clear access patterns

## Database Logical Separation

The package supports database logical separation through:

```typescript
import { DATABASE_SCHEMAS, TABLE_OWNERSHIP, isTableOwnedByService } from '@delicasa/shared-types';

// Check table ownership
const isBridgeServerTable = isTableOwnedByService('controllers', 'BRIDGE_SERVER'); // true
const isNextClientTable = isTableOwnedByService('orders', 'NEXT_CLIENT'); // true

// Use appropriate schema
const schema = DATABASE_SCHEMAS.BRIDGE_SERVER_PRIVATE; // 'bridgeserver_private'
```

## Event-Driven Communication

Services communicate through domain events:

```typescript
import { EventHandler, ContainerStatusChanged } from '@delicasa/shared-types';

// In Next-Client: Subscribe to BridgeServer events
const containerStatusHandler: EventHandler<ContainerStatusChanged> = async (event) => {
  // Update business logic when container status changes
  await updateContainerAvailability(event.payload.containerId, event.payload.newStatus);
  await notifyAffectedUsers(event.payload.containerId);
  await updateAnalytics(event);
};

eventBus.subscribe(DOMAIN_EVENT_TYPES.CONTAINER_STATUS_CHANGED, containerStatusHandler);
```

## Type Safety Features

The package provides strong type safety:

```typescript
import { Result, isSuccess, isFailure } from '@delicasa/shared-types';

async function processOrder(orderId: string): Promise<void> {
  const orderResult = await orderService.getOrderById(orderId);
  
  if (isSuccess(orderResult)) {
    // TypeScript knows orderResult.data is Order
    console.log(`Processing order: ${orderResult.data.id}`);
    const paymentResult = await paymentService.processPayment({
      amount: orderResult.data.totalAmount,
      currency: 'USD',
      paymentMethodId: orderResult.data.paymentMethod
    });
    
    if (isFailure(paymentResult)) {
      // TypeScript knows paymentResult.error is Error
      throw paymentResult.error;
    }
  } else {
    // TypeScript knows orderResult.error is Error
    throw new Error(`Order not found: ${orderResult.error.message}`);
  }
}
```

## Development

### Building the Package

```bash
cd shared
npm install
npm run build
```

### Type Checking

```bash
npm run typecheck
```

### Development Mode

```bash
npm run dev  # Watch mode
```

## Contributing

When adding new types or interfaces:

1. Follow the existing naming conventions
2. Add comprehensive JSDoc documentation
3. Include the new exports in `index.ts`
4. Update this README if needed
5. Ensure backward compatibility

## Versioning

This package follows semantic versioning. Breaking changes will increment the major version.

Current version: `1.0.0`

## License

Private - DeliCasa Development Team