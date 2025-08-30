/**
 * Shared Domain Entity Interfaces and Base Types
 * 
 * These interfaces define the contract for domain entities across both
 * BridgeServer and next-client projects following DDD principles.
 */

import type { DomainEvent } from './base-repository';

// Re-export DomainEvent so it's available from this module
export type { DomainEvent } from './base-repository';

/**
 * Base identifier type for all entities
 */
export type EntityId = string;

/**
 * Base interface for all domain entities
 */
export interface BaseEntity {
  id: EntityId;
  createdAt: Date;
  updatedAt: Date;
}

/**
 * Interface for entities that can be soft deleted
 */
export interface SoftDeletableEntity extends BaseEntity {
  deletedAt?: Date;
  isDeleted: boolean;
}

/**
 * Interface for entities with audit information
 */
export interface AuditableEntity extends BaseEntity {
  createdBy?: string;
  updatedBy?: string;
  version: number;
}

/**
 * Base aggregate root interface for DDD aggregates
 */
export interface AggregateRoot extends BaseEntity {
  /**
   * Get uncommitted domain events
   */
  getUncommittedEvents(): DomainEvent[];

  /**
   * Mark all events as committed
   */
  markEventsAsCommitted(): void;

  /**
   * Add a domain event to be published
   */
  addDomainEvent(event: DomainEvent): void;

  /**
   * Clear all uncommitted events
   */
  clearEvents(): void;
}

/**
 * Base value object interface
 */
export interface ValueObject {
  /**
   * Compare with another value object for equality
   */
  equals(other: ValueObject): boolean;

  /**
   * Get a string representation of the value object
   */
  toString(): string;
}

// ========================================
// Shared Domain Entities
// ========================================

/**
 * User entity - shared between both services
 */
export interface User extends AuditableEntity {
  name: string;
  email: string;
  role: UserRole;
  externalId?: string;
  phoneNumber?: string;
  isActive: boolean;
  lastLoginAt?: Date;
  profile?: UserProfile;
}

/**
 * User profile entity
 */
export interface UserProfile extends BaseEntity {
  userId: string;
  firstName?: string;
  lastName?: string;
  avatar?: string;
  preferences: UserPreferences;
  address?: Address;
}

/**
 * User preferences value object
 */
export interface UserPreferences extends ValueObject {
  language: string;
  timezone: string;
  notifications: NotificationPreferences;
  theme: 'light' | 'dark' | 'auto';
}

/**
 * Notification preferences
 */
export interface NotificationPreferences {
  email: boolean;
  sms: boolean;
  push: boolean;
  orderUpdates: boolean;
  systemAlerts: boolean;
  marketing: boolean;
}

/**
 * Address value object
 */
export interface Address extends ValueObject {
  street: string;
  city: string;
  state?: string;
  postalCode: string;
  country: string;
  coordinates?: Coordinates;
}

/**
 * Coordinates value object
 */
export interface Coordinates extends ValueObject {
  latitude: number;
  longitude: number;
  accuracy?: number;
}

/**
 * Controller entity - shared between both services
 */
export interface Controller extends AuditableEntity {
  name: string;
  location?: string;
  coordinates?: Coordinates;
  ipAddress?: string;
  macAddress?: string;
  serialNumber?: string;
  hardwareSignature?: string;
  apiEndpoint?: string;
  deviceType: DeviceType;
  connectionType: ConnectionType;
  status: ControllerStatus;
  capabilities: string[];
  osInfo?: string;
  metadata?: Record<string, any>;
  token?: string;
  lastSeen: Date;
  description?: string;
}

/**
 * Device entity - shared between both services
 */
export interface Device extends AuditableEntity {
  macAddress: string;
  ipAddress: string;
  firmwareVersion: string;
  token: string;
  status: DeviceStatus;
  deviceType: DeviceType;
  lastSeen: Date;
  containerId?: string;
  shelfLevel?: number;
  position?: string;
  name?: string;
  description?: string;
  batteryLevel?: number;
  temperature?: number;
}

/**
 * Container entity - shared between both services
 */
export interface Container extends AuditableEntity {
  controllerId: string;
  name: string;
  description?: string;
  deviceType: DeviceType;
  position?: string;
  shelfLevel?: number;
  capacity: number;
  isActive: boolean;
  status: ContainerStatus;
  location?: string;
  metadata?: Record<string, any>;
}

/**
 * Order entity - primarily Next-Client but read by BridgeServer
 */
export interface Order extends AuditableEntity {
  userId: string;
  containerId?: string;
  status: OrderStatus;
  totalAmount: number;
  subtotal: number;
  tax: number;
  deliveryFee: number;
  discountAmount?: number;
  paymentMethod: string;
  paymentStatus: PaymentStatus;
  deliveryAddress?: Address;
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  notes?: string;
  items: OrderItem[];
}

/**
 * Order item value object
 */
export interface OrderItem extends ValueObject {
  productId: string;
  productName: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
  metadata?: Record<string, any>;
}

/**
 * Payment entity - primarily Next-Client
 */
export interface Payment extends AuditableEntity {
  userId: string;
  orderId?: string;
  sessionId?: string;
  paymentMethodId?: string;
  stripePaymentIntentId?: string;
  amount: number;
  currency: string;
  status: PaymentStatus;
  description?: string;
  metadata?: Record<string, any>;
}

/**
 * Payment method entity - primarily Next-Client
 */
export interface PaymentMethod extends AuditableEntity {
  userId: string;
  stripePaymentMethodId: string;
  type: PaymentMethodType;
  brand?: string;
  lastFour?: string;
  expiryMonth?: number;
  expiryYear?: number;
  isDefault: boolean;
  isActive: boolean;
}

// ========================================
// Enumerations and Status Types
// ========================================

export enum UserRole {
  ADMIN = 'ADMIN',
  USER = 'USER',
  PROVIDER = 'PROVIDER',
  CUSTOMER = 'CUSTOMER'
}

export enum DeviceType {
  ESP32 = 'esp32',
  ESP_CAM = 'esp-cam',
  RASPBERRY_PI = 'raspberry-pi',
  CAMERA = 'camera',
  SENSOR = 'sensor',
  CONTROLLER = 'controller'
}

export enum ConnectionType {
  WIFI = 'wifi',
  ETHERNET = 'ethernet',
  BLUETOOTH = 'bluetooth',
  CELLULAR = 'cellular',
  OTHER = 'other'
}

export enum ControllerStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  ERROR = 'error',
  MAINTENANCE = 'maintenance',
  CONFIGURING = 'configuring'
}

export enum DeviceStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  ERROR = 'error',
  MAINTENANCE = 'maintenance',
  UPDATING = 'updating'
}

export enum ContainerStatus {
  ONLINE = 'online',
  OFFLINE = 'offline',
  MAINTENANCE = 'maintenance',
  ERROR = 'error',
  FULL = 'full',
  EMPTY = 'empty'
}

export enum OrderStatus {
  PENDING = 'pending',
  CONFIRMED = 'confirmed',
  PREPARING = 'preparing',
  READY = 'ready',
  DELIVERED = 'delivered',
  CANCELLED = 'cancelled'
}

export enum PaymentStatus {
  PENDING = 'pending',
  PROCESSING = 'processing',
  SUCCEEDED = 'succeeded',
  FAILED = 'failed',
  CANCELLED = 'cancelled',
  REFUNDED = 'refunded'
}

export enum PaymentMethodType {
  CARD = 'card',
  BANK_ACCOUNT = 'bank_account',
  DIGITAL_WALLET = 'digital_wallet'
}

// ========================================
// Domain Event Types
// ========================================

/**
 * User domain events
 */
export interface UserRegistered extends DomainEvent {
  type: 'UserRegistered';
  payload: {
    userId: string;
    email: string;
    role: UserRole;
  };
}

export interface UserProfileUpdated extends DomainEvent {
  type: 'UserProfileUpdated';
  payload: {
    userId: string;
    changes: Partial<UserProfile>;
  };
}

/**
 * Controller domain events
 */
export interface ControllerStatusChanged extends DomainEvent {
  type: 'ControllerStatusChanged';
  payload: {
    controllerId: string;
    previousStatus: ControllerStatus;
    newStatus: ControllerStatus;
    reason?: string;
  };
}

export interface ControllerRegistered extends DomainEvent {
  type: 'ControllerRegistered';
  payload: {
    controllerId: string;
    macAddress: string;
    location?: string;
  };
}

/**
 * Device domain events
 */
export interface DeviceStatusChanged extends DomainEvent {
  type: 'DeviceStatusChanged';
  payload: {
    deviceId: string;
    controllerId?: string;
    previousStatus: DeviceStatus;
    newStatus: DeviceStatus;
    batteryLevel?: number;
    temperature?: number;
  };
}

export interface DeviceRegistered extends DomainEvent {
  type: 'DeviceRegistered';
  payload: {
    deviceId: string;
    macAddress: string;
    deviceType: DeviceType;
    controllerId?: string;
  };
}

/**
 * Container domain events
 */
export interface ContainerStatusChanged extends DomainEvent {
  type: 'ContainerStatusChanged';
  payload: {
    containerId: string;
    controllerId: string;
    previousStatus: ContainerStatus;
    newStatus: ContainerStatus;
    capacity?: number;
  };
}

/**
 * Order domain events
 */
export interface OrderCreated extends DomainEvent {
  type: 'OrderCreated';
  payload: {
    orderId: string;
    userId: string;
    totalAmount: number;
    containerId?: string;
  };
}

export interface OrderStatusChanged extends DomainEvent {
  type: 'OrderStatusChanged';
  payload: {
    orderId: string;
    userId: string;
    previousStatus: OrderStatus;
    newStatus: OrderStatus;
  };
}

/**
 * Payment domain events
 */
export interface PaymentProcessed extends DomainEvent {
  type: 'PaymentProcessed';
  payload: {
    paymentId: string;
    orderId?: string;
    userId: string;
    amount: number;
    status: PaymentStatus;
  };
}

export interface PaymentMethodAdded extends DomainEvent {
  type: 'PaymentMethodAdded';
  payload: {
    paymentMethodId: string;
    userId: string;
    type: PaymentMethodType;
    isDefault: boolean;
  };
}

// ========================================
// Utility Types
// ========================================

/**
 * Type for creating entities without auto-generated fields
 */
export type CreateEntity<T extends BaseEntity> = Omit<T, 'id' | 'createdAt' | 'updatedAt'>;

/**
 * Type for updating entities (all fields optional except id)
 */
export type UpdateEntity<T extends BaseEntity> = Partial<Omit<T, 'id' | 'createdAt'>> & {
  id: EntityId;
};

/**
 * Type for entity filters
 */
export type EntityFilter<T> = Partial<T> & {
  ids?: EntityId[];
  createdAfter?: Date;
  createdBefore?: Date;
  updatedAfter?: Date;
  updatedBefore?: Date;
};

/**
 * Type for sorting options
 */
export type SortOptions<T> = {
  [K in keyof T]?: 'asc' | 'desc';
};

/**
 * Type for field selection
 */
export type FieldSelection<T> = {
  [K in keyof T]?: boolean;
};

/**
 * Generic result type for operations that might fail
 */
export type Result<T, E = Error> = {
  success: true;
  data: T;
} | {
  success: false;
  error: E;
};