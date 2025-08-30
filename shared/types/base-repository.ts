/**
 * Shared Base Repository Interfaces for Hexagonal Architecture
 * 
 * These interfaces define the contract that all repository adapters must implement
 * across both BridgeServer and next-client projects.
 */

/**
 * Basic filter options for repository queries
 */
export interface FilterOptions {
  limit?: number;
  offset?: number;
  sortBy?: string;
  sortOrder?: 'asc' | 'desc';
  search?: string;
  filters?: Record<string, any>;
}

/**
 * Pagination metadata for query results
 */
export interface PaginationMeta {
  total: number;
  page: number;
  limit: number;
  totalPages: number;
  hasNext: boolean;
  hasPrevious: boolean;
}

/**
 * Paginated response wrapper
 */
export interface PaginatedResponse<T> {
  data: T[];
  meta: PaginationMeta;
}

/**
 * Base repository interface that all repositories must implement
 * Provides standard CRUD operations with consistent method signatures
 */
export interface BaseRepository<TEntity, TId = string> {
  /**
   * Find an entity by its unique identifier
   * @param id - The unique identifier
   * @returns Promise resolving to the entity or null if not found
   */
  findById(id: TId): Promise<TEntity | null>;

  /**
   * Find multiple entities based on filter criteria
   * @param filters - Optional filter criteria
   * @returns Promise resolving to array of entities
   */
  findAll(filters?: FilterOptions): Promise<TEntity[]>;

  /**
   * Find entities with pagination support
   * @param filters - Filter criteria with pagination options
   * @returns Promise resolving to paginated response
   */
  findAllPaginated(filters?: FilterOptions): Promise<PaginatedResponse<TEntity>>;

  /**
   * Save a new entity or update existing one
   * @param entity - The entity to save
   * @returns Promise resolving to the saved entity
   */
  save(entity: TEntity): Promise<TEntity>;

  /**
   * Update an existing entity by ID
   * @param id - The entity ID
   * @param updates - Partial entity data for updates
   * @returns Promise resolving to the updated entity
   */
  update(id: TId, updates: Partial<TEntity>): Promise<TEntity>;

  /**
   * Delete an entity by ID
   * @param id - The entity ID
   * @returns Promise resolving when deletion is complete
   */
  delete(id: TId): Promise<void>;

  /**
   * Check if an entity exists by ID
   * @param id - The entity ID
   * @returns Promise resolving to boolean indicating existence
   */
  exists(id: TId): Promise<boolean>;

  /**
   * Count entities matching the filter criteria
   * @param filters - Optional filter criteria
   * @returns Promise resolving to the count
   */
  count(filters?: FilterOptions): Promise<number>;

  /**
   * Find a single entity matching the filter criteria
   * @param filters - Filter criteria
   * @returns Promise resolving to entity or null if not found
   */
  findOne(filters: FilterOptions): Promise<TEntity | null>;

  /**
   * Create multiple entities in a transaction
   * @param entities - Array of entities to create
   * @returns Promise resolving to array of created entities
   */
  createMany(entities: TEntity[]): Promise<TEntity[]>;

  /**
   * Update multiple entities matching criteria
   * @param filters - Filter criteria for entities to update
   * @param updates - Partial entity data for updates
   * @returns Promise resolving to number of updated entities
   */
  updateMany(filters: FilterOptions, updates: Partial<TEntity>): Promise<number>;

  /**
   * Delete multiple entities matching criteria
   * @param filters - Filter criteria for entities to delete
   * @returns Promise resolving to number of deleted entities
   */
  deleteMany(filters: FilterOptions): Promise<number>;
}

/**
 * Repository interface for entities that support soft deletion
 */
export interface SoftDeletableRepository<TEntity, TId = string> extends BaseRepository<TEntity, TId> {
  /**
   * Soft delete an entity (mark as deleted without physical removal)
   * @param id - The entity ID
   * @returns Promise resolving when soft deletion is complete
   */
  softDelete(id: TId): Promise<void>;

  /**
   * Restore a soft-deleted entity
   * @param id - The entity ID
   * @returns Promise resolving to the restored entity
   */
  restore(id: TId): Promise<TEntity>;

  /**
   * Find all entities including soft-deleted ones
   * @param filters - Optional filter criteria
   * @returns Promise resolving to array of entities including soft-deleted
   */
  findAllWithDeleted(filters?: FilterOptions): Promise<TEntity[]>;

  /**
   * Find only soft-deleted entities
   * @param filters - Optional filter criteria
   * @returns Promise resolving to array of soft-deleted entities
   */
  findDeleted(filters?: FilterOptions): Promise<TEntity[]>;

  /**
   * Permanently delete a soft-deleted entity
   * @param id - The entity ID
   * @returns Promise resolving when permanent deletion is complete
   */
  forceDelete(id: TId): Promise<void>;
}

/**
 * Repository interface for entities with audit fields (createdAt, updatedAt, etc.)
 */
export interface AuditableRepository<TEntity, TId = string> extends BaseRepository<TEntity, TId> {
  /**
   * Find entities created within a date range
   * @param startDate - Start date
   * @param endDate - End date
   * @param filters - Additional filter criteria
   * @returns Promise resolving to array of entities
   */
  findByDateRange(startDate: Date, endDate: Date, filters?: FilterOptions): Promise<TEntity[]>;

  /**
   * Find entities modified within a date range
   * @param startDate - Start date
   * @param endDate - End date
   * @param filters - Additional filter criteria
   * @returns Promise resolving to array of entities
   */
  findModifiedInRange(startDate: Date, endDate: Date, filters?: FilterOptions): Promise<TEntity[]>;

  /**
   * Get audit trail for an entity
   * @param id - The entity ID
   * @returns Promise resolving to audit information
   */
  getAuditTrail(id: TId): Promise<AuditTrail[]>;
}

/**
 * Audit trail entry
 */
export interface AuditTrail {
  id: string;
  entityId: string;
  entityType: string;
  action: 'create' | 'update' | 'delete' | 'restore';
  changes: Record<string, { old: any; new: any }>;
  userId?: string;
  timestamp: Date;
  metadata?: Record<string, any>;
}

/**
 * Generic transaction interface for repository operations
 */
export interface TransactionContext {
  id: string;
  isActive: boolean;
  commit(): Promise<void>;
  rollback(): Promise<void>;
}

/**
 * Repository interface with transaction support
 */
export interface TransactionalRepository<TEntity, TId = string> extends BaseRepository<TEntity, TId> {
  /**
   * Execute operations within a transaction
   * @param callback - Function containing operations to execute in transaction
   * @returns Promise resolving to the callback result
   */
  withTransaction<TResult>(
    callback: (repository: this) => Promise<TResult>
  ): Promise<TResult>;

  /**
   * Set the transaction context for operations
   * @param transaction - The transaction context
   */
  setTransaction(transaction: TransactionContext): void;

  /**
   * Get the current transaction context
   * @returns The current transaction context or null
   */
  getTransaction(): TransactionContext | null;
}

/**
 * Event-aware repository interface for domain events
 */
export interface EventAwareRepository<TEntity, TId = string> extends BaseRepository<TEntity, TId> {
  /**
   * Save entity and publish domain events
   * @param entity - The entity to save
   * @param events - Domain events to publish
   * @returns Promise resolving to the saved entity
   */
  saveWithEvents(entity: TEntity, events: DomainEvent[]): Promise<TEntity>;

  /**
   * Update entity and publish domain events
   * @param id - The entity ID
   * @param updates - Partial entity data for updates
   * @param events - Domain events to publish
   * @returns Promise resolving to the updated entity
   */
  updateWithEvents(id: TId, updates: Partial<TEntity>, events: DomainEvent[]): Promise<TEntity>;

  /**
   * Delete entity and publish domain events
   * @param id - The entity ID
   * @param events - Domain events to publish
   * @returns Promise resolving when deletion is complete
   */
  deleteWithEvents(id: TId, events: DomainEvent[]): Promise<void>;
}

/**
 * Base domain event interface
 */
export interface DomainEvent {
  id: string;
  type: string;
  aggregateId: string;
  aggregateType: string;
  version: number;
  timestamp: Date;
  userId?: string;
  metadata?: Record<string, any>;
  payload: Record<string, any>;
}