/**
 * Service Port Interfaces for Hexagonal Architecture
 * 
 * These ports define the contracts for application services, domain services,
 * and external service integrations across both BridgeServer and next-client projects.
 */

import type {
  User,
  Controller,
  Device,
  Container,
  Order,
  Payment,
  PaymentMethod,
  DomainEvent,
  ControllerStatus,
  DeviceStatus,
  ContainerStatus,
  OrderStatus,
  PaymentStatus,
  Coordinates,
  Result
} from '../types/domain-entities';

import type { FilterOptions } from '../types/base-repository';

// ========================================
// Application Service Ports
// ========================================

export interface UserManagementServicePort {
  registerUser(userData: RegisterUserCommand): Promise<Result<User>>;
  authenticateUser(credentials: AuthenticationCredentials): Promise<Result<AuthenticationResult>>;
  updateProfile(userId: string, profileData: UpdateProfileCommand): Promise<Result<User>>;
  deactivateUser(userId: string, reason?: string): Promise<Result<void>>;
  changeUserRole(userId: string, newRole: string, changedBy: string): Promise<Result<User>>;
  resetPassword(email: string): Promise<Result<void>>;
  changePassword(userId: string, oldPassword: string, newPassword: string): Promise<Result<void>>;
  getUserById(userId: string): Promise<Result<User>>;
  searchUsers(query: string, filters?: FilterOptions): Promise<Result<User[]>>;
}

export interface ControllerManagementServicePort {
  registerController(controllerData: RegisterControllerCommand): Promise<Result<ControllerRegistrationResult>>;
  updateControllerStatus(controllerId: string, status: ControllerStatus, reason?: string): Promise<Result<void>>;
  assignDeviceToController(controllerId: string, deviceId: string): Promise<Result<void>>;
  removeDeviceFromController(controllerId: string, deviceId: string): Promise<Result<void>>;
  getControllerById(controllerId: string): Promise<Result<Controller>>;
  findControllersByLocation(location: string, radius?: number): Promise<Result<Controller[]>>;
  updateControllerConfiguration(controllerId: string, config: ControllerConfiguration): Promise<Result<void>>;
  getControllerMetrics(controllerId: string, timeRange: TimeRange): Promise<Result<ControllerMetrics>>;
}

export interface DeviceManagementServicePort {
  registerDevice(deviceData: RegisterDeviceCommand): Promise<Result<DeviceRegistrationResult>>;
  updateDeviceStatus(deviceId: string, status: DeviceStatus): Promise<Result<void>>;
  updateDeviceMetrics(deviceId: string, metrics: DeviceMetrics): Promise<Result<void>>;
  assignToContainer(deviceId: string, containerId: string): Promise<Result<void>>;
  removeFromContainer(deviceId: string): Promise<Result<void>>;
  getDeviceById(deviceId: string): Promise<Result<Device>>;
  findDevicesByController(controllerId: string): Promise<Result<Device[]>>;
  updateFirmware(deviceId: string, firmwareVersion: string): Promise<Result<void>>;
  performDiagnostics(deviceId: string): Promise<Result<DiagnosticsResult>>;
}

export interface ContainerManagementServicePort {
  createContainer(containerData: CreateContainerCommand): Promise<Result<Container>>;
  updateContainerStatus(containerId: string, status: ContainerStatus): Promise<Result<void>>;
  assignToController(containerId: string, controllerId: string): Promise<Result<void>>;
  updateCapacity(containerId: string, capacity: number): Promise<Result<void>>;
  getContainerById(containerId: string): Promise<Result<Container>>;
  findAvailableContainers(location?: string, deviceType?: string): Promise<Result<Container[]>>;
  getContainerUtilization(containerId: string, timeRange: TimeRange): Promise<Result<ContainerUtilization>>;
  scheduleMaintenence(containerId: string, maintenanceData: ScheduleMaintenanceCommand): Promise<Result<void>>;
}

export interface OrderManagementServicePort {
  createOrder(orderData: CreateOrderCommand): Promise<Result<Order>>;
  updateOrderStatus(orderId: string, status: OrderStatus): Promise<Result<void>>;
  cancelOrder(orderId: string, reason?: string): Promise<Result<void>>;
  processPayment(orderId: string, paymentData: ProcessPaymentCommand): Promise<Result<Payment>>;
  getOrderById(orderId: string): Promise<Result<Order>>;
  getUserOrders(userId: string, filters?: FilterOptions): Promise<Result<Order[]>>;
  calculateOrderTotal(items: OrderItem[], userId?: string): Promise<Result<OrderCalculation>>;
  estimateDeliveryTime(orderId: string): Promise<Result<Date>>;
  updateDeliveryStatus(orderId: string, deliveryData: UpdateDeliveryCommand): Promise<Result<void>>;
}

export interface PaymentManagementServicePort {
  processPayment(paymentData: ProcessPaymentCommand): Promise<Result<Payment>>;
  refundPayment(paymentId: string, amount?: number, reason?: string): Promise<Result<Payment>>;
  savePaymentMethod(userId: string, paymentMethodData: SavePaymentMethodCommand): Promise<Result<PaymentMethod>>;
  removePaymentMethod(paymentMethodId: string): Promise<Result<void>>;
  setDefaultPaymentMethod(userId: string, paymentMethodId: string): Promise<Result<void>>;
  getUserPaymentMethods(userId: string): Promise<Result<PaymentMethod[]>>;
  validatePaymentMethod(paymentMethodId: string): Promise<Result<boolean>>;
  getPaymentHistory(userId: string, filters?: FilterOptions): Promise<Result<Payment[]>>;
}

// ========================================
// Domain Service Ports
// ========================================

export interface DeviceDomainServicePort {
  calculateOptimalPlacement(devices: Device[], containers: Container[]): Promise<PlacementRecommendation[]>;
  validateDeviceCompatibility(deviceType: string, containerType: string): boolean;
  assessDeviceHealth(device: Device, metrics: DeviceMetrics[]): HealthAssessment;
  predictMaintenanceNeeds(device: Device, historicalData: DeviceMetrics[]): MaintenancePrediction;
  optimizePowerUsage(devices: Device[]): PowerOptimizationPlan;
}

export interface PaymentDomainServicePort {
  validatePaymentAmount(amount: number, currency: string): ValidationResult;
  calculateFees(amount: number, paymentMethod: PaymentMethod): FeeCalculation;
  assessFraudRisk(payment: Payment, user: User): FraudRiskAssessment;
  validatePaymentPolicy(payment: Payment, user: User): PolicyValidationResult;
  generatePaymentReceipt(payment: Payment, order?: Order): PaymentReceipt;
}

export interface UserDomainServicePort {
  validateUserPermissions(userId: string, resource: string, action: string): Promise<boolean>;
  calculateUserLoyaltyLevel(user: User, orderHistory: Order[]): LoyaltyLevel;
  assessUserCreditworthiness(user: User, paymentHistory: Payment[]): CreditAssessment;
  generateUserRecommendations(user: User, orderHistory: Order[]): ProductRecommendation[];
  validateUserAction(user: User, action: string, context: ActionContext): ValidationResult;
}

export interface InventoryDomainServicePort {
  calculateStockLevels(containerId: string): Promise<StockLevel>;
  predictDemand(productId: string, timeRange: TimeRange): DemandPrediction;
  optimizeRestocking(containers: Container[], inventory: InventoryItem[]): RestockingPlan;
  detectAnomalies(stockData: StockData[]): AnomalyDetection[];
  calculateTurnoverRate(productId: string, timeRange: TimeRange): number;
}

// ========================================
// External Service Integration Ports
// ========================================

export interface NotificationServicePort {
  sendEmail(to: string, subject: string, content: string, template?: string): Promise<Result<void>>;
  sendSMS(to: string, message: string): Promise<Result<void>>;
  sendPushNotification(userId: string, notification: PushNotification): Promise<Result<void>>;
  sendInAppNotification(userId: string, notification: InAppNotification): Promise<Result<void>>;
  subscribeToTopic(userId: string, topic: string): Promise<Result<void>>;
  unsubscribeFromTopic(userId: string, topic: string): Promise<Result<void>>;
  getNotificationHistory(userId: string, filters?: FilterOptions): Promise<Result<NotificationHistory[]>>;
}

export interface AuthenticationServicePort {
  authenticate(credentials: AuthenticationCredentials): Promise<Result<AuthenticationResult>>;
  generateToken(user: User, type: TokenType): Promise<Result<AuthToken>>;
  validateToken(token: string, type: TokenType): Promise<Result<TokenValidationResult>>;
  refreshToken(refreshToken: string): Promise<Result<AuthToken>>;
  revokeToken(token: string): Promise<Result<void>>;
  generatePasswordResetToken(email: string): Promise<Result<string>>;
  validatePasswordResetToken(token: string): Promise<Result<boolean>>;
  changePassword(userId: string, oldPassword: string, newPassword: string): Promise<Result<void>>;
}

export interface PaymentGatewayServicePort {
  createPaymentIntent(amount: number, currency: string, metadata?: Record<string, any>): Promise<Result<PaymentIntent>>;
  confirmPayment(paymentIntentId: string, paymentMethodId: string): Promise<Result<PaymentResult>>;
  capturePayment(paymentIntentId: string, amount?: number): Promise<Result<PaymentResult>>;
  refundPayment(paymentIntentId: string, amount?: number, reason?: string): Promise<Result<RefundResult>>;
  savePaymentMethod(userId: string, paymentMethodData: any): Promise<Result<string>>;
  retrievePaymentMethod(paymentMethodId: string): Promise<Result<any>>;
  deletePaymentMethod(paymentMethodId: string): Promise<Result<void>>;
  listPaymentMethods(userId: string): Promise<Result<any[]>>;
}

export interface ImageStorageServicePort {
  uploadImage(file: File, metadata?: ImageMetadata): Promise<Result<ImageUploadResult>>;
  getImageUrl(imageId: string, size?: ImageSize): Promise<Result<string>>;
  deleteImage(imageId: string): Promise<Result<void>>;
  processImage(imageId: string, operations: ImageOperation[]): Promise<Result<ProcessedImageResult>>;
  generateThumbnail(imageId: string, size: ImageSize): Promise<Result<string>>;
  getImageMetadata(imageId: string): Promise<Result<ImageMetadata>>;
  listImages(filters?: FilterOptions): Promise<Result<ImageInfo[]>>;
}

export interface ComputerVisionServicePort {
  analyzeImage(imageId: string, analysisType: AnalysisType[]): Promise<Result<VisionAnalysisResult>>;
  detectObjects(imageId: string): Promise<Result<ObjectDetectionResult>>;
  recognizeText(imageId: string): Promise<Result<TextRecognitionResult>>;
  classifyImage(imageId: string): Promise<Result<ImageClassificationResult>>;
  compareImages(imageId1: string, imageId2: string): Promise<Result<ImageComparisonResult>>;
  extractFeatures(imageId: string): Promise<Result<ImageFeatures>>;
  detectAnomalies(imageId: string, baselineImages: string[]): Promise<Result<AnomalyDetectionResult>>;
}

export interface CacheServicePort {
  get<T>(key: string): Promise<T | null>;
  set<T>(key: string, value: T, ttl?: number): Promise<void>;
  delete(key: string): Promise<void>;
  exists(key: string): Promise<boolean>;
  increment(key: string, amount?: number): Promise<number>;
  decrement(key: string, amount?: number): Promise<number>;
  expire(key: string, ttl: number): Promise<void>;
  flush(): Promise<void>;
  getKeys(pattern: string): Promise<string[]>;
}

export interface EventBusServicePort {
  publish(event: DomainEvent): Promise<void>;
  publishMany(events: DomainEvent[]): Promise<void>;
  subscribe<T extends DomainEvent>(eventType: string, handler: EventHandler<T>): void;
  unsubscribe(eventType: string, handlerId?: string): void;
  getEventHistory(aggregateId: string, eventTypes?: string[]): Promise<DomainEvent[]>;
  replay(aggregateId: string, fromVersion?: number): Promise<void>;
}

export interface LoggingServicePort {
  debug(message: string, context?: LogContext): void;
  info(message: string, context?: LogContext): void;
  warn(message: string, context?: LogContext): void;
  error(message: string, error?: Error, context?: LogContext): void;
  critical(message: string, error?: Error, context?: LogContext): void;
  createLogger(component: string): LoggingServicePort;
  setLogLevel(level: LogLevel): void;
  flush(): Promise<void>;
}

// ========================================
// Command and Query Types
// ========================================

export interface RegisterUserCommand {
  email: string;
  password: string;
  name: string;
  role?: string;
  phoneNumber?: string;
}

export interface RegisterControllerCommand {
  name: string;
  macAddress: string;
  location?: string;
  coordinates?: Coordinates;
  deviceType: string;
  capabilities: string[];
}

export interface RegisterDeviceCommand {
  macAddress: string;
  ipAddress: string;
  deviceType: string;
  firmwareVersion: string;
  controllerId?: string;
}

export interface CreateContainerCommand {
  name: string;
  controllerId: string;
  deviceType: string;
  capacity: number;
  position?: string;
  description?: string;
}

export interface CreateOrderCommand {
  userId: string;
  items: OrderItem[];
  deliveryAddress?: string;
  paymentMethodId?: string;
  containerId?: string;
}

export interface ProcessPaymentCommand {
  amount: number;
  currency: string;
  paymentMethodId: string;
  orderId?: string;
  description?: string;
}

export interface UpdateProfileCommand {
  name?: string;
  phoneNumber?: string;
  preferences?: Record<string, any>;
  address?: string;
}

// ========================================
// Result Types
// ========================================

export interface AuthenticationResult {
  user: User;
  accessToken: string;
  refreshToken: string;
  expiresAt: Date;
}

export interface ControllerRegistrationResult {
  controller: Controller;
  token: string;
  configurationEndpoint: string;
}

export interface DeviceRegistrationResult {
  device: Device;
  authToken: string;
  configurationUrl: string;
}

export interface OrderCalculation {
  subtotal: number;
  tax: number;
  deliveryFee: number;
  discounts: number;
  total: number;
  estimatedDeliveryTime: Date;
}

export interface PaymentIntent {
  id: string;
  amount: number;
  currency: string;
  status: string;
  clientSecret: string;
}

export interface PaymentResult {
  id: string;
  status: PaymentStatus;
  amount: number;
  transactionId?: string;
}

// ========================================
// Supporting Types and Enums
// ========================================

export interface TimeRange {
  start: Date;
  end: Date;
}

export interface AuthenticationCredentials {
  email: string;
  password: string;
}

export interface DeviceMetrics {
  batteryLevel?: number;
  temperature?: number;
  cpuUsage?: number;
  memoryUsage?: number;
  networkStatus?: string;
  timestamp: Date;
}

export interface ControllerConfiguration {
  settings: Record<string, any>;
  capabilities: string[];
  endpoints: Record<string, string>;
}

export interface OrderItem {
  productId: string;
  quantity: number;
  price: number;
}

export type TokenType = 'access' | 'refresh' | 'reset' | 'verification';

export type LogLevel = 'debug' | 'info' | 'warn' | 'error' | 'critical';

export type AnalysisType = 'object_detection' | 'text_recognition' | 'classification' | 'anomaly_detection';

export type ImageSize = 'thumbnail' | 'small' | 'medium' | 'large' | 'original';

export interface LogContext {
  userId?: string;
  requestId?: string;
  component?: string;
  action?: string;
  metadata?: Record<string, any>;
}

export interface EventHandler<T extends DomainEvent> {
  (event: T): Promise<void>;
}

// ========================================
// Additional Supporting Types
// ========================================

export interface ControllerMetrics {
  uptime: number;
  cpuUsage: number;
  memoryUsage: number;
  networkLatency: number;
  deviceCount: number;
  errorCount: number;
  lastUpdate: Date;
}

export interface DiagnosticsResult {
  deviceId: string;
  overallHealth: 'healthy' | 'warning' | 'critical';
  tests: DiagnosticTest[];
  recommendations: string[];
  timestamp: Date;
}

export interface DiagnosticTest {
  name: string;
  status: 'pass' | 'fail' | 'warning';
  message: string;
  details?: Record<string, any>;
}

export interface ContainerUtilization {
  containerId: string;
  utilizationPercentage: number;
  averageOrdersPerDay: number;
  peakUsageHours: number[];
  revenueGenerated: number;
  period: TimeRange;
}

export interface ScheduleMaintenanceCommand {
  scheduledDate: Date;
  maintenanceType: string;
  description: string;
  estimatedDuration: number; // minutes
  assignedTechnician?: string;
}

export interface UpdateDeliveryCommand {
  estimatedDeliveryTime?: Date;
  actualDeliveryTime?: Date;
  deliveryNotes?: string;
  trackingNumber?: string;
}

export interface SavePaymentMethodCommand {
  type: string;
  stripePaymentMethodId: string;
  isDefault?: boolean;
  billingAddress?: string;
}

export interface PlacementRecommendation {
  deviceId: string;
  recommendedContainerId: string;
  confidence: number;
  reasoning: string;
  expectedUtilization: number;
}

export interface HealthAssessment {
  overallScore: number; // 0-100
  factors: {
    battery: number;
    connectivity: number;
    performance: number;
    uptime: number;
  };
  alerts: string[];
  recommendations: string[];
}

export interface MaintenancePrediction {
  deviceId: string;
  predictedMaintenanceDate: Date;
  confidence: number;
  reasons: string[];
  recommendedActions: string[];
}

export interface PowerOptimizationPlan {
  deviceId: string;
  currentPowerUsage: number; // watts
  optimizedPowerUsage: number; // watts
  savingsPercentage: number;
  recommendations: PowerRecommendation[];
}

export interface PowerRecommendation {
  action: string;
  expectedSavings: number; // watts
  implementation: string;
}

export interface ValidationResult {
  isValid: boolean;
  errors: string[];
  warnings?: string[];
}

export interface FeeCalculation {
  processingFee: number;
  platformFee: number;
  totalFees: number;
  currency: string;
}

export interface FraudRiskAssessment {
  riskScore: number; // 0-100
  riskLevel: 'low' | 'medium' | 'high';
  factors: string[];
  requiresAdditionalVerification: boolean;
}

export interface PolicyValidationResult {
  isCompliant: boolean;
  violations: string[];
  requiredActions: string[];
}

export interface PaymentReceipt {
  receiptId: string;
  paymentId: string;
  amount: number;
  currency: string;
  timestamp: Date;
  merchantInfo: {
    name: string;
    address: string;
    taxId: string;
  };
  items: ReceiptItem[];
  taxes: TaxBreakdown[];
}

export interface ReceiptItem {
  description: string;
  quantity: number;
  unitPrice: number;
  totalPrice: number;
}

export interface TaxBreakdown {
  type: string;
  rate: number;
  amount: number;
}

export interface LoyaltyLevel {
  level: string;
  points: number;
  tier: 'bronze' | 'silver' | 'gold' | 'platinum';
  benefits: string[];
  nextTierRequirements?: string;
}

export interface CreditAssessment {
  creditScore: number;
  creditLimit: number;
  paymentHistory: 'excellent' | 'good' | 'fair' | 'poor';
  riskLevel: 'low' | 'medium' | 'high';
  recommendations: string[];
}

export interface ProductRecommendation {
  productId: string;
  productName: string;
  confidence: number;
  reason: string;
  expectedPrice: number;
}

export interface ActionContext {
  source: string;
  timestamp: Date;
  metadata: Record<string, any>;
  userAgent?: string;
  ipAddress?: string;
}

export interface StockLevel {
  containerId: string;
  totalCapacity: number;
  currentStock: number;
  availableSpace: number;
  utilizationPercentage: number;
  itemBreakdown: StockItem[];
}

export interface StockItem {
  productId: string;
  quantity: number;
  location: string;
  lastUpdated: Date;
}

export interface DemandPrediction {
  productId: string;
  predictedDemand: number;
  period: TimeRange;
  confidence: number;
  factors: string[];
}

export interface InventoryItem {
  productId: string;
  quantity: number;
  location: string;
  lastRestocked: Date;
  minimumThreshold: number;
}

export interface RestockingPlan {
  containerId: string;
  items: RestockItem[];
  priority: 'high' | 'medium' | 'low';
  estimatedCost: number;
  suggestedDate: Date;
}

export interface RestockItem {
  productId: string;
  currentQuantity: number;
  suggestedQuantity: number;
  reason: string;
}

export interface StockData {
  timestamp: Date;
  productId: string;
  quantity: number;
  location: string;
  changeType: 'restock' | 'sale' | 'adjustment' | 'expiry';
}

export interface AnomalyDetection {
  type: 'stock_discrepancy' | 'unusual_consumption' | 'temperature_anomaly';
  severity: 'low' | 'medium' | 'high';
  description: string;
  detectedAt: Date;
  affectedItems: string[];
  suggestedActions: string[];
}

export interface PushNotification {
  title: string;
  body: string;
  data?: Record<string, any>;
  badge?: number;
  sound?: string;
  category?: string;
}

export interface InAppNotification {
  type: string;
  title: string;
  message: string;
  actionUrl?: string;
  priority: 'low' | 'normal' | 'high';
  expiresAt?: Date;
}

export interface NotificationHistory {
  id: string;
  type: string;
  title: string;
  message: string;
  sentAt: Date;
  deliveredAt?: Date;
  readAt?: Date;
  status: 'sent' | 'delivered' | 'read' | 'failed';
}

export interface AuthToken {
  token: string;
  type: TokenType;
  expiresAt: Date;
  scope?: string[];
}

export interface TokenValidationResult {
  isValid: boolean;
  userId?: string;
  expiresAt?: Date;
  scope?: string[];
  errors?: string[];
}

export interface RefundResult {
  refundId: string;
  amount: number;
  status: 'pending' | 'processed' | 'failed';
  reason?: string;
  processedAt?: Date;
}

export interface ImageMetadata {
  filename: string;
  size: number;
  mimeType: string;
  width: number;
  height: number;
  capturedAt?: Date;
  deviceId?: string;
  location?: Coordinates;
  tags?: string[];
}

export interface ImageUploadResult {
  imageId: string;
  url: string;
  thumbnailUrl: string;
  metadata: ImageMetadata;
}

export interface ImageOperation {
  type: 'resize' | 'crop' | 'rotate' | 'filter' | 'compress';
  parameters: Record<string, any>;
}

export interface ProcessedImageResult {
  processedImageId: string;
  originalImageId: string;
  operations: ImageOperation[];
  url: string;
  metadata: ImageMetadata;
}

export interface ImageInfo {
  id: string;
  filename: string;
  url: string;
  thumbnailUrl: string;
  size: number;
  uploadedAt: Date;
  tags: string[];
}

export interface VisionAnalysisResult {
  imageId: string;
  analysisType: AnalysisType;
  results: Record<string, any>;
  confidence: number;
  processingTime: number;
  timestamp: Date;
}

export interface ObjectDetectionResult {
  objects: DetectedObject[];
  totalObjects: number;
  processingTime: number;
}

export interface DetectedObject {
  type: string;
  confidence: number;
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  attributes?: Record<string, any>;
}

export interface TextRecognitionResult {
  text: string;
  words: RecognizedWord[];
  confidence: number;
  language?: string;
}

export interface RecognizedWord {
  text: string;
  confidence: number;
  boundingBox: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
}

export interface ImageClassificationResult {
  categories: ClassificationCategory[];
  primaryCategory: string;
  confidence: number;
}

export interface ClassificationCategory {
  name: string;
  confidence: number;
  subcategories?: string[];
}

export interface ImageComparisonResult {
  similarity: number; // 0-1
  differences: ImageDifference[];
  isMatch: boolean;
  threshold: number;
}

export interface ImageDifference {
  type: string;
  location: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  severity: 'low' | 'medium' | 'high';
}

export interface ImageFeatures {
  colorHistogram: number[];
  edges: number[];
  textures: number[];
  shapes: string[];
  dominantColors: string[];
}

export interface AnomalyDetectionResult {
  isAnomaly: boolean;
  anomalyScore: number; // 0-1
  anomalies: DetectedAnomaly[];
  baseline: string;
}

export interface DetectedAnomaly {
  type: string;
  severity: 'low' | 'medium' | 'high';
  location?: {
    x: number;
    y: number;
    width: number;
    height: number;
  };
  description: string;
}