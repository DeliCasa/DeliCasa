/**
 * Repository Port Interfaces for Hexagonal Architecture
 * 
 * These ports define the contracts for all repository implementations
 * across both BridgeServer and next-client projects.
 */

import type {
  BaseRepository,
  SoftDeletableRepository,
  AuditableRepository,
  TransactionalRepository,
  EventAwareRepository,
  FilterOptions,
  PaginatedResponse
} from '../types/base-repository';

import type {
  User,
  UserProfile,
  Controller,
  Device,
  Container,
  Order,
  Payment,
  PaymentMethod,
  UserRole,
  ControllerStatus,
  DeviceStatus,
  ContainerStatus,
  OrderStatus,
  PaymentStatus,
  DeviceType,
  Coordinates
} from '../types/domain-entities';

// ========================================
// User Management Ports
// ========================================

export interface UserRepositoryPort extends 
  BaseRepository<User>, 
  AuditableRepository<User>, 
  EventAwareRepository<User> {
  
  findByEmail(email: string): Promise<User | null>;
  findByExternalId(externalId: string): Promise<User | null>;
  findByRole(role: UserRole, filters?: FilterOptions): Promise<User[]>;
  findActiveUsers(filters?: FilterOptions): Promise<User[]>;
  updateLastLogin(id: string, timestamp: Date): Promise<void>;
  deactivateUser(id: string): Promise<void>;
  activateUser(id: string): Promise<void>;
  changeRole(id: string, newRole: UserRole): Promise<User>;
}

export interface UserProfileRepositoryPort extends BaseRepository<UserProfile> {
  findByUserId(userId: string): Promise<UserProfile | null>;
  updatePreferences(userId: string, preferences: Partial<UserProfile['preferences']>): Promise<UserProfile>;
  findByLocation(coordinates: Coordinates, radiusKm: number): Promise<UserProfile[]>;
}

// ========================================
// IoT/Hardware Ports (Primarily BridgeServer)
// ========================================

export interface ControllerRepositoryPort extends 
  BaseRepository<Controller>, 
  AuditableRepository<Controller>,
  EventAwareRepository<Controller> {
  
  findByMacAddress(macAddress: string): Promise<Controller | null>;
  findBySerialNumber(serialNumber: string): Promise<Controller | null>;
  findByHardwareSignature(signature: string): Promise<Controller | null>;
  findByHardwareIdentifiers(
    macAddress?: string,
    serialNumber?: string,
    hardwareSignature?: string
  ): Promise<Controller | null>;
  findByLocation(location: string): Promise<Controller[]>;
  findByStatus(status: ControllerStatus, filters?: FilterOptions): Promise<Controller[]>;
  findByCapability(capability: string): Promise<Controller[]>;
  findByGeoArea(lat1: number, lon1: number, lat2: number, lon2: number): Promise<Controller[]>;
  updateStatus(id: string, status: ControllerStatus, reason?: string): Promise<void>;
  updateToken(id: string, token: string): Promise<void>;
  updateLastSeen(id: string, timestamp: Date): Promise<void>;
  getCameraCount(controllerId: string): Promise<number>;
  getDeviceCount(controllerId: string): Promise<number>;
  findNearby(coordinates: Coordinates, radiusKm: number): Promise<Controller[]>;
}

export interface DeviceRepositoryPort extends 
  BaseRepository<Device>, 
  AuditableRepository<Device>,
  EventAwareRepository<Device> {
  
  findByMacAddress(macAddress: string): Promise<Device | null>;
  findByControllerId(controllerId: string): Promise<Device[]>;
  findByStatus(status: DeviceStatus, filters?: FilterOptions): Promise<Device[]>;
  findByDeviceType(deviceType: DeviceType, filters?: FilterOptions): Promise<Device[]>;
  findByContainer(containerId: string): Promise<Device[]>;
  updateStatus(id: string, status: DeviceStatus): Promise<void>;
  updateLastSeen(id: string, timestamp: Date): Promise<void>;
  updateBatteryLevel(id: string, level: number): Promise<void>;
  updateTemperature(id: string, temperature: number): Promise<void>;
  assignToContainer(deviceId: string, containerId: string): Promise<void>;
  removeFromContainer(deviceId: string): Promise<void>;
  findLowBattery(threshold: number): Promise<Device[]>;
  findByFirmwareVersion(version: string): Promise<Device[]>;
}

export interface ContainerRepositoryPort extends 
  BaseRepository<Container>, 
  AuditableRepository<Container>,
  EventAwareRepository<Container> {
  
  findByControllerId(controllerId: string): Promise<Container[]>;
  findByStatus(status: ContainerStatus, filters?: FilterOptions): Promise<Container[]>;
  findByLocation(location: string): Promise<Container[]>;
  findAvailable(filters?: FilterOptions): Promise<Container[]>;
  updateStatus(id: string, status: ContainerStatus): Promise<void>;
  updateCapacity(id: string, capacity: number): Promise<void>;
  findByDeviceType(deviceType: DeviceType): Promise<Container[]>;
  getDevicesInContainer(containerId: string): Promise<Device[]>;
  findNearLocation(location: string, radiusKm?: number): Promise<Container[]>;
}

// ========================================
// Business Logic Ports (Primarily Next-Client)
// ========================================

export interface OrderRepositoryPort extends 
  BaseRepository<Order>, 
  AuditableRepository<Order>,
  EventAwareRepository<Order> {
  
  findByUserId(userId: string, filters?: FilterOptions): Promise<Order[]>;
  findByStatus(status: OrderStatus, filters?: FilterOptions): Promise<Order[]>;
  findByContainer(containerId: string, filters?: FilterOptions): Promise<Order[]>;
  findByPaymentStatus(paymentStatus: PaymentStatus, filters?: FilterOptions): Promise<Order[]>;
  updateStatus(id: string, status: OrderStatus): Promise<void>;
  updatePaymentStatus(id: string, paymentStatus: PaymentStatus): Promise<void>;
  setDeliveryTime(id: string, estimatedTime?: Date, actualTime?: Date): Promise<void>;
  findPendingOrders(olderThan?: Date): Promise<Order[]>;
  findOrdersInDateRange(startDate: Date, endDate: Date): Promise<Order[]>;
  calculateRevenue(startDate?: Date, endDate?: Date): Promise<number>;
  getOrderStatistics(startDate?: Date, endDate?: Date): Promise<OrderStatistics>;
}

export interface PaymentRepositoryPort extends 
  BaseRepository<Payment>, 
  AuditableRepository<Payment>,
  EventAwareRepository<Payment> {
  
  findByUserId(userId: string, filters?: FilterOptions): Promise<Payment[]>;
  findByOrderId(orderId: string): Promise<Payment[]>;
  findByStatus(status: PaymentStatus, filters?: FilterOptions): Promise<Payment[]>;
  findByStripePaymentIntentId(stripeId: string): Promise<Payment | null>;
  updateStatus(id: string, status: PaymentStatus): Promise<void>;
  findByDateRange(startDate: Date, endDate: Date): Promise<Payment[]>;
  calculateTotalAmount(filters?: FilterOptions): Promise<number>;
  findFailedPayments(olderThan?: Date): Promise<Payment[]>;
  findRefundablePayments(filters?: FilterOptions): Promise<Payment[]>;
}

export interface PaymentMethodRepositoryPort extends 
  BaseRepository<PaymentMethod>, 
  SoftDeletableRepository<PaymentMethod> {
  
  findByUserId(userId: string): Promise<PaymentMethod[]>;
  findByStripePaymentMethodId(stripeId: string): Promise<PaymentMethod | null>;
  findDefaultForUser(userId: string): Promise<PaymentMethod | null>;
  setAsDefault(id: string, userId: string): Promise<void>;
  deactivate(id: string): Promise<void>;
  activate(id: string): Promise<void>;
  findActiveForUser(userId: string): Promise<PaymentMethod[]>;
}

// ========================================
// Analytics and Monitoring Ports
// ========================================

export interface AnalyticsRepositoryPort {
  recordUserActivity(
    userId: string, 
    action: string, 
    entityType: string, 
    entityId?: string,
    metadata?: Record<string, any>
  ): Promise<void>;
  
  recordSystemMetric(
    metricName: string, 
    value: number, 
    tags?: Record<string, string>
  ): Promise<void>;
  
  recordDeviceMetric(
    deviceId: string, 
    metricType: string, 
    value: number,
    timestamp?: Date
  ): Promise<void>;
  
  getUserActivityStats(
    userId: string, 
    startDate: Date, 
    endDate: Date
  ): Promise<UserActivityStats>;
  
  getSystemMetrics(
    metricNames: string[], 
    startDate: Date, 
    endDate: Date
  ): Promise<SystemMetricsData>;
  
  getDeviceMetrics(
    deviceIds: string[], 
    metricTypes: string[], 
    startDate: Date, 
    endDate: Date
  ): Promise<DeviceMetricsData>;
  
  getOrderAnalytics(
    startDate: Date, 
    endDate: Date
  ): Promise<OrderAnalytics>;
  
  getRevenueAnalytics(
    startDate: Date, 
    endDate: Date,
    groupBy?: 'day' | 'week' | 'month'
  ): Promise<RevenueAnalytics>;
}

export interface AuditLogRepositoryPort extends BaseRepository<AuditLogEntry> {
  logUserAction(
    userId: string,
    action: string,
    entityType: string,
    entityId: string,
    changes?: Record<string, any>,
    ipAddress?: string,
    userAgent?: string
  ): Promise<void>;
  
  logSystemEvent(
    eventType: string,
    severity: 'info' | 'warning' | 'error' | 'critical',
    message: string,
    metadata?: Record<string, any>
  ): Promise<void>;
  
  findByUser(userId: string, filters?: FilterOptions): Promise<AuditLogEntry[]>;
  findByEntity(entityType: string, entityId: string, filters?: FilterOptions): Promise<AuditLogEntry[]>;
  findByDateRange(startDate: Date, endDate: Date, filters?: FilterOptions): Promise<AuditLogEntry[]>;
  findByAction(action: string, filters?: FilterOptions): Promise<AuditLogEntry[]>;
}

// ========================================
// Specialized Search and Query Ports
// ========================================

export interface SearchRepositoryPort {
  searchUsers(query: string, filters?: FilterOptions): Promise<User[]>;
  searchControllers(query: string, filters?: FilterOptions): Promise<Controller[]>;
  searchDevices(query: string, filters?: FilterOptions): Promise<Device[]>;
  searchContainers(query: string, filters?: FilterOptions): Promise<Container[]>;
  searchOrders(query: string, filters?: FilterOptions): Promise<Order[]>;
  searchAll(query: string, entityTypes?: string[], filters?: FilterOptions): Promise<SearchResult[]>;
}

// ========================================
// Supporting Types
// ========================================

export interface OrderStatistics {
  totalOrders: number;
  totalRevenue: number;
  averageOrderValue: number;
  ordersByStatus: Record<OrderStatus, number>;
  ordersByContainer: Record<string, number>;
  ordersByTimeOfDay: Record<string, number>;
}

export interface UserActivityStats {
  totalActions: number;
  actionsByType: Record<string, number>;
  lastActivity: Date;
  averageSessionDuration: number;
  deviceUsage: Record<string, number>;
}

export interface SystemMetricsData {
  metrics: {
    name: string;
    values: { timestamp: Date; value: number }[];
  }[];
  aggregatedData: Record<string, number>;
}

export interface DeviceMetricsData {
  deviceMetrics: {
    deviceId: string;
    metrics: {
      type: string;
      values: { timestamp: Date; value: number }[];
    }[];
  }[];
}

export interface OrderAnalytics {
  totalOrders: number;
  completedOrders: number;
  cancelledOrders: number;
  averageOrderValue: number;
  peakOrderTimes: { hour: number; count: number }[];
  topContainers: { containerId: string; orderCount: number }[];
  orderTrends: { date: string; count: number }[];
}

export interface RevenueAnalytics {
  totalRevenue: number;
  revenueByPeriod: { period: string; revenue: number }[];
  revenueByContainer: { containerId: string; revenue: number }[];
  averageTransactionValue: number;
  revenueGrowth: number; // percentage
}

export interface AuditLogEntry {
  id: string;
  userId?: string;
  action: string;
  entityType: string;
  entityId?: string;
  description: string;
  changes?: Record<string, any>;
  ipAddress?: string;
  userAgent?: string;
  severity: 'info' | 'warning' | 'error' | 'critical';
  timestamp: Date;
  metadata?: Record<string, any>;
}

export interface SearchResult {
  id: string;
  type: string;
  title: string;
  description?: string;
  metadata?: Record<string, any>;
  score: number; // relevance score
}