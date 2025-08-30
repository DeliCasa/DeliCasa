/**
 * DeliCasa Shared Types and Interfaces
 * 
 * This package provides shared TypeScript types and interfaces for implementing
 * hexagonal architecture with ports and adapters across BridgeServer and next-client projects.
 * 
 * @version 1.0.0
 * @author DeliCasa Development Team
 */

// ========================================
// Base Repository Interfaces and Types
// ========================================

export type {
  FilterOptions,
  PaginationMeta,
  PaginatedResponse,
  BaseRepository,
  SoftDeletableRepository,
  AuditableRepository,
  TransactionContext,
  TransactionalRepository,
  EventAwareRepository,
  DomainEvent,
  AuditTrail
} from './types/base-repository';

// ========================================
// Domain Entities and Value Objects
// ========================================

export type {
  EntityId,
  BaseEntity,
  SoftDeletableEntity,
  AuditableEntity,
  AggregateRoot,
  ValueObject,
  
  // Core Entities
  User,
  UserProfile,
  UserPreferences,
  NotificationPreferences,
  Address,
  Coordinates,
  Controller,
  Device,
  Container,
  Order,
  OrderItem,
  Payment,
  PaymentMethod,
  
  // Domain Events
  UserRegistered,
  UserProfileUpdated,
  ControllerStatusChanged,
  ControllerRegistered,
  DeviceStatusChanged,
  DeviceRegistered,
  ContainerStatusChanged,
  OrderCreated,
  OrderStatusChanged,
  PaymentProcessed,
  PaymentMethodAdded,
  
  // Utility Types
  CreateEntity,
  UpdateEntity,
  EntityFilter,
  SortOptions,
  FieldSelection,
  Result
} from './types/domain-entities';

// Export enums
export {
  UserRole,
  DeviceType,
  ConnectionType,
  ControllerStatus,
  DeviceStatus,
  ContainerStatus,
  OrderStatus,
  PaymentStatus,
  PaymentMethodType
} from './types/domain-entities';

// ========================================
// Repository Port Interfaces
// ========================================

export type {
  UserRepositoryPort,
  UserProfileRepositoryPort,
  ControllerRepositoryPort,
  DeviceRepositoryPort,
  ContainerRepositoryPort,
  OrderRepositoryPort,
  PaymentRepositoryPort,
  PaymentMethodRepositoryPort,
  AnalyticsRepositoryPort,
  AuditLogRepositoryPort,
  SearchRepositoryPort,
  
  // Supporting Types
  OrderStatistics,
  UserActivityStats,
  SystemMetricsData,
  DeviceMetricsData,
  OrderAnalytics,
  RevenueAnalytics,
  AuditLogEntry,
  SearchResult
} from './ports/repository-ports';

// ========================================
// Service Port Interfaces
// ========================================

export type {
  // Application Services
  UserManagementServicePort,
  ControllerManagementServicePort,
  DeviceManagementServicePort,
  ContainerManagementServicePort,
  OrderManagementServicePort,
  PaymentManagementServicePort,
  
  // Domain Services
  DeviceDomainServicePort,
  PaymentDomainServicePort,
  UserDomainServicePort,
  InventoryDomainServicePort,
  
  // External Service Integration Ports
  NotificationServicePort,
  AuthenticationServicePort,
  PaymentGatewayServicePort,
  ImageStorageServicePort,
  ComputerVisionServicePort,
  CacheServicePort,
  EventBusServicePort,
  LoggingServicePort,
  
  // Commands
  RegisterUserCommand,
  RegisterControllerCommand,
  RegisterDeviceCommand,
  CreateContainerCommand,
  CreateOrderCommand,
  ProcessPaymentCommand,
  UpdateProfileCommand,
  
  // Results and Response Types
  AuthenticationResult,
  ControllerRegistrationResult,
  DeviceRegistrationResult,
  OrderCalculation,
  PaymentIntent,
  PaymentResult,
  
  // Supporting Types
  TimeRange,
  AuthenticationCredentials,
  DeviceMetrics,
  ControllerMetrics,
  ControllerConfiguration,
  TokenType,
  LogLevel,
  AnalysisType,
  ImageSize,
  LogContext,
  EventHandler
} from './ports/service-ports';

// ========================================
// tRPC Router Types
// ========================================

export type {
  AppRouter,
  HealthCheckOutput,
  DetailedHealthOutput,
  ControllerListInput,
  ControllerOutput,
  ControllerListOutput,
  ControllerDetailOutput,
  UpdateControllerStatusInput,
  UpdateControllerStatusOutput
} from './ports/trpc-router';

export {
  HealthCheckOutputSchema,
  DetailedHealthOutputSchema,
  ControllerListInputSchema,
  ControllerOutputSchema,
  ControllerListOutputSchema,
  ControllerDetailOutputSchema,
  UpdateControllerStatusInputSchema,
  UpdateControllerStatusOutputSchema
} from './ports/trpc-router';

// ========================================
// Constants and Configuration
// ========================================

/**
 * Default pagination settings
 */
export const DEFAULT_PAGINATION = {
  limit: 20,
  offset: 0,
  maxLimit: 100
} as const;

/**
 * Default filter options
 */
export const DEFAULT_FILTER_OPTIONS = {
  limit: DEFAULT_PAGINATION.limit,
  offset: DEFAULT_PAGINATION.offset,
  sortOrder: 'desc' as const
};

/**
 * Service boundary constants
 */
export const SERVICE_BOUNDARIES = {
  BRIDGE_SERVER: 'bridge-server',
  NEXT_CLIENT: 'next-client'
} as const;

/**
 * Event type constants
 */
export const DOMAIN_EVENT_TYPES = {
  // User Events
  USER_REGISTERED: 'UserRegistered',
  USER_PROFILE_UPDATED: 'UserProfileUpdated',
  
  // Controller Events
  CONTROLLER_STATUS_CHANGED: 'ControllerStatusChanged',
  CONTROLLER_REGISTERED: 'ControllerRegistered',
  
  // Device Events
  DEVICE_STATUS_CHANGED: 'DeviceStatusChanged',
  DEVICE_REGISTERED: 'DeviceRegistered',
  
  // Container Events
  CONTAINER_STATUS_CHANGED: 'ContainerStatusChanged',
  
  // Order Events
  ORDER_CREATED: 'OrderCreated',
  ORDER_STATUS_CHANGED: 'OrderStatusChanged',
  
  // Payment Events
  PAYMENT_PROCESSED: 'PaymentProcessed',
  PAYMENT_METHOD_ADDED: 'PaymentMethodAdded'
} as const;

/**
 * Table ownership mapping for shared database strategy
 */
export const TABLE_OWNERSHIP = {
  // BridgeServer owns these tables
  BRIDGE_SERVER: [
    'controllers',
    'devices', 
    'images',
    'vision_analysis',
    'stock_analysis',
    'commands',
    'categories'
  ],
  
  // Next-Client owns these tables
  NEXT_CLIENT: [
    'users',
    'user_profiles',
    'orders',
    'payments',
    'payment_methods',
    'sessions',
    'transactions',
    'transaction_items',
    'analytics',
    'audit_logs',
    'system_alerts',
    'system_metrics',
    'user_activity_metrics',
    'transaction_metrics',
    'service_status',
    'activity_log',
    'device_status_history'
  ],
  
  // Shared access (with ownership specified)
  SHARED: [
    'containers', // Owned by BridgeServer, read access for Next-Client
    'inventory',  // Hybrid ownership
    'products'    // Hybrid ownership
  ]
} as const;

/**
 * Database schema names for logical separation
 */
export const DATABASE_SCHEMAS = {
  BRIDGE_SERVER_PRIVATE: 'bridgeserver_private',
  NEXT_CLIENT_PRIVATE: 'nextclient_private',
  SHARED_READONLY: 'shared_readonly'
} as const;

// ========================================
// Utility Functions
// ========================================

/**
 * Generate a new entity ID
 */
export function generateEntityId(): string {
  // Simple UUID v4 generator for Node.js/browser compatibility
  if (typeof crypto !== 'undefined' && crypto.randomUUID) {
    return crypto.randomUUID();
  }
  
  // Fallback implementation
  return 'xxxxxxxx-xxxx-4xxx-yxxx-xxxxxxxxxxxx'.replace(/[xy]/g, function(c) {
    const r = Math.random() * 16 | 0;
    const v = c === 'x' ? r : (r & 0x3 | 0x8);
    return v.toString(16);
  });
}

/**
 * Create a domain event
 */
export function createDomainEvent<T extends Record<string, any>>(
  type: string,
  aggregateId: string,
  aggregateType: string,
  payload: T,
  userId?: string,
  metadata?: Record<string, any>
) {
  return {
    id: generateEntityId(),
    type,
    aggregateId,
    aggregateType,
    version: 1,
    timestamp: new Date(),
    userId,
    metadata,
    payload: payload as Record<string, any>
  };
}

/**
 * Check if a table is owned by a specific service
 */
export function isTableOwnedByService(tableName: string, service: keyof typeof TABLE_OWNERSHIP): boolean {
  const serviceTables = TABLE_OWNERSHIP[service];
  return Array.isArray(serviceTables) && serviceTables.includes(tableName);
}

/**
 * Get the owner service for a table
 */
export function getTableOwner(tableName: string): keyof typeof TABLE_OWNERSHIP | null {
  for (const [service, tables] of Object.entries(TABLE_OWNERSHIP)) {
    if (Array.isArray(tables) && tables.includes(tableName)) {
      return service as keyof typeof TABLE_OWNERSHIP;
    }
  }
  return null;
}

/**
 * Create a successful result
 */
export function success<T>(data: T) {
  return { success: true as const, data };
}

/**
 * Create an error result
 */
export function failure<E>(error: E) {
  return { success: false as const, error };
}

/**
 * Type guard for successful results
 */
export function isSuccess<T, E>(result: { success: boolean; data?: T; error?: E }): result is { success: true; data: T } {
  return result.success;
}

/**
 * Type guard for error results
 */
export function isFailure<T, E>(result: { success: boolean; data?: T; error?: E }): result is { success: false; error: E } {
  return !result.success;
}

// ========================================
// Version and Metadata
// ========================================

export const SHARED_TYPES_VERSION = '1.0.0';

export const ARCHITECTURE_METADATA = {
  pattern: 'hexagonal-architecture',
  alias: 'ports-and-adapters',
  approach: 'domain-driven-design',
  databaseStrategy: 'shared-with-logical-separation',
  communicationPattern: 'domain-events'
} as const;