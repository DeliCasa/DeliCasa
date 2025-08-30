-- Converted from SQLite to PostgreSQL
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;


CREATE TABLE IF NOT EXISTS "__drizzle_migrations" (
			id SERIAL PRIMARY KEY,
			hash TEXT NOT NULL,
			created_at NUMERIC
		);
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'3f68b718f56d96df3eebb3b7ef25b3d5a81fa40b097eccf9f9a457fe460f9fa5',1744909926010);
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'c134185762599fee149f514b656ff8a3fe3e34f4dc3d9ac8a15796828a651e65',1745008678765);
INSERT INTO "__drizzle_migrations" VALUES(DEFAULT,'10994a841ba3a2ef998bea3e2e0ed3119d450d30f0fa1577ccf24683f68fb358',1745268391351);
INSERT INTO "__drizzle_migrations" VALUES(1,'',1750261052000);
CREATE TABLE "devices" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"mac_address" TEXT NOT NULL,
	"ip_address" TEXT NOT NULL,
	"firmware_version" TEXT NOT NULL,
	"token" TEXT NOT NULL,
	"status" TEXT DEFAULT 'offline' NOT NULL,
	"device_type" TEXT NOT NULL,
	"last_seen" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
, "container_id" TEXT REFERENCES "containers"("id"), "shelf_level" INTEGER, "position" TEXT, "name" TEXT, "description" TEXT, "metadata" TEXT);
INSERT INTO "devices" VALUES('cam-E6B4','auto:cam-E6B4','0.0.0.0','unknown','','online','camera',1756406230,1753632895,1756406230,NULL,NULL,NULL,'Camera cam-E6B4','Auto-registered camera from controller raspberr-mb8b9trx-e45f','{"autoRegistered":TRUE,"registeredAt":"2025-07-27T16:14:55.927Z","parentController":"raspberr-mb8b9trx-e45f"}');
INSERT INTO "devices" VALUES('cam-0A24','auto:cam-0A24','0.0.0.0','unknown','','online','camera',1756403920,1753723867,1756403920,NULL,NULL,NULL,'Camera cam-0A24','Auto-registered camera from controller raspberr-mb8b9trx-e45f','{"autoRegistered":TRUE,"registeredAt":"2025-07-28T17:31:07.467Z","parentController":"raspberr-mb8b9trx-e45f"}');
CREATE TABLE "images" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"filename" TEXT NOT NULL,
	"url" TEXT NOT NULL,
	"device_id" TEXT NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL, "container_id" TEXT REFERENCES "containers"("id"), "shelf_level" INTEGER, "position" TEXT, "metadata" TEXT, "taken_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("device_id") REFERENCES ""devices""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "controllers" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"location" TEXT,
	"latitude" REAL,
	"longitude" REAL,
	"ip_address" TEXT,
	"api_endpoint" TEXT,
	"device_type" TEXT NOT NULL,
	"connection_type" TEXT DEFAULT 'other' NOT NULL,
	"status" TEXT DEFAULT 'offline' NOT NULL,
	"capabilities" TEXT NOT NULL,
	"os_info" TEXT,
	"metadata" TEXT,
	"token" TEXT,
	"last_seen" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
, mac_address TEXT, serial_number TEXT, hardware_signature TEXT, description TEXT);
INSERT INTO "controllers" VALUES('raspberr-mb8b9trx-e45f','DelicasaPi-Kitchen-001','Kitchen Area',NULL,NULL,'192.168.1.124','https://pi-api.delicasa.workers.dev','vending_machine','cloudflare_tunnel','online','["door_control","image_capture","ping"]','linux/arm64','{"deploymentTime":"2025-08-28T18:55:55+01:00"}','1756322727150.ze45gmo25.6165e7f8',1756406233,1753632865,1756406233,'e4:5f:01:15:cd:36',NULL,NULL,NULL);
CREATE TABLE IF NOT EXISTS "commands" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"device_id" TEXT,
	"container_id" TEXT,
	"type" TEXT NOT NULL,
	"status" TEXT DEFAULT 'pending' NOT NULL,
	"parameters" TEXT,
	"result" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("device_id") REFERENCES ""devices""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("container_id") REFERENCES ""controllers""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "analytics" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"controller_id" TEXT,
	"user_id" TEXT,
	"metric_type" TEXT NOT NULL,
	"metric_name" TEXT NOT NULL,
	"value" REAL NOT NULL,
	"unit" TEXT,
	"dimensions" TEXT,
	"metadata" TEXT,
	"aggregation_period" TEXT,
	"recorded_at" INTEGER NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("controller_id") REFERENCES ""controllers""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE set null
);
CREATE TABLE "audit_logs" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"user_id" TEXT,
	"entity_type" TEXT NOT NULL,
	"entity_id" TEXT NOT NULL,
	"action" TEXT NOT NULL,
	"old_values" TEXT,
	"new_values" TEXT,
	"ip_address" TEXT,
	"user_agent" TEXT,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE set null
);
CREATE TABLE "categories" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"description" TEXT,
	"parent_id" TEXT,
	"sort_order" INTEGER DEFAULT 0,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("parent_id") REFERENCES ""categories""(""id"") ON UPDATE no action ON DELETE no action
);
CREATE TABLE "inventory" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"controller_id" TEXT NOT NULL,
	"product_id" TEXT NOT NULL,
	"stock_level" INTEGER DEFAULT 0 NOT NULL,
	"min_threshold" INTEGER DEFAULT 5 NOT NULL,
	"max_capacity" INTEGER DEFAULT 50 NOT NULL,
	"shelf_level" INTEGER,
	"position" TEXT,
	"price_override" REAL,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"last_restocked" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("controller_id") REFERENCES ""controllers""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("product_id") REFERENCES ""products""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "payment_methods" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"user_id" TEXT NOT NULL,
	"stripe_payment_method_id" TEXT NOT NULL,
	"type" TEXT NOT NULL,
	"brand" TEXT,
	"last4" TEXT,
	"expiry_month" INTEGER,
	"expiry_year" INTEGER,
	"is_default" INTEGER DEFAULT FALSE NOT NULL,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "payments" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"transaction_id" TEXT NOT NULL,
	"user_id" TEXT NOT NULL,
	"payment_method_id" TEXT,
	"stripe_payment_intent_id" TEXT NOT NULL,
	"amount" REAL NOT NULL,
	"currency" TEXT DEFAULT 'BRL' NOT NULL,
	"status" TEXT DEFAULT 'pending' NOT NULL,
	"failure_reason" TEXT,
	"refund_amount" REAL DEFAULT 0,
	"fees" REAL DEFAULT 0,
	"metadata" TEXT,
	"processed_at" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("transaction_id") REFERENCES ""transactions""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("payment_method_id") REFERENCES ""payment_methods""(""id"") ON UPDATE no action ON DELETE no action
);
CREATE TABLE "products" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"description" TEXT,
	"sku" TEXT NOT NULL,
	"barcode" TEXT,
	"category_id" TEXT,
	"base_price" REAL NOT NULL,
	"weight" REAL,
	"dimensions" TEXT,
	"image_url" TEXT,
	"cv_model_id" TEXT,
	"cv_confidence_threshold" REAL DEFAULT 0.85,
	"nutritional_info" TEXT,
	"allergens" TEXT,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("category_id") REFERENCES ""categories""(""id"") ON UPDATE no action ON DELETE no action
);
CREATE TABLE "sessions" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"controller_id" TEXT NOT NULL,
	"user_id" TEXT,
	"qr_code" TEXT NOT NULL,
	"status" TEXT DEFAULT 'pending' NOT NULL,
	"expires_at" INTEGER NOT NULL,
	"activated_at" INTEGER,
	"completed_at" INTEGER,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL, total_amount REAL, tax_amount REAL, session_data TEXT,
	FOREIGN KEY ("controller_id") REFERENCES ""controllers""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE set null
);
CREATE TABLE "transaction_items" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"transaction_id" TEXT NOT NULL,
	"product_id" TEXT NOT NULL,
	"quantity" INTEGER DEFAULT 1 NOT NULL,
	"unit_price" REAL NOT NULL,
	"total_price" REAL NOT NULL,
	"detected_confidence" REAL,
	"shelf_level" INTEGER,
	"position" TEXT,
	"metadata" TEXT,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("transaction_id") REFERENCES ""transactions""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("product_id") REFERENCES ""products""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "transactions" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"session_id" TEXT NOT NULL,
	"user_id" TEXT NOT NULL,
	"controller_id" TEXT NOT NULL,
	"subtotal" REAL DEFAULT 0 NOT NULL,
	"tax_amount" REAL DEFAULT 0 NOT NULL,
	"discount_amount" REAL DEFAULT 0 NOT NULL,
	"total_amount" REAL DEFAULT 0 NOT NULL,
	"status" TEXT DEFAULT 'pending' NOT NULL,
	"payment_status" TEXT DEFAULT 'pending' NOT NULL,
	"cv_analysis_status" TEXT DEFAULT 'pending' NOT NULL,
	"cv_confidence_score" REAL,
	"metadata" TEXT,
	"processing_started_at" INTEGER,
	"completed_at" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("session_id") REFERENCES ""sessions""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("controller_id") REFERENCES ""controllers""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "user_profiles" (
	"user_id" TEXT PRIMARY KEY NOT NULL,
	"avatar" TEXT,
	"address" TEXT,
	"city" TEXT,
	"state" TEXT,
	"zip_code" TEXT,
	"country" TEXT DEFAULT 'BR',
	"preferences" TEXT,
	"loyalty_points" INTEGER DEFAULT 0 NOT NULL,
	"total_orders" INTEGER DEFAULT 0 NOT NULL,
	"total_spent" REAL DEFAULT 0 NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("user_id") REFERENCES ""users""(""id"") ON UPDATE no action ON DELETE cascade
);
CREATE TABLE "users" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"name" TEXT NOT NULL,
	"email" TEXT NOT NULL,
	"role" TEXT DEFAULT 'USER' NOT NULL,
	"external_id" TEXT,
	"phone_number" TEXT,
	"is_active" INTEGER DEFAULT TRUE NOT NULL,
	"last_login_at" INTEGER,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"updated_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE "vision_analysis" (
	"id" TEXT PRIMARY KEY NOT NULL,
	"image_id" TEXT NOT NULL,
	"transaction_id" TEXT,
	"analysis_type" TEXT DEFAULT 'product_detection' NOT NULL,
	"detected_items" TEXT NOT NULL,
	"confidence_scores" TEXT NOT NULL,
	"bounding_boxes" TEXT,
	"processing_time" INTEGER,
	"model_version" TEXT,
	"status" TEXT DEFAULT 'completed' NOT NULL,
	"error_message" TEXT,
	"metadata" TEXT,
	"processed_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	"created_at" INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY ("image_id") REFERENCES ""images""(""id"") ON UPDATE no action ON DELETE cascade,
	FOREIGN KEY ("transaction_id") REFERENCES ""transactions""(""id"") ON UPDATE no action ON DELETE set null
);
CREATE TABLE d1_migrations(
		id         SERIAL PRIMARY KEY,
		name       TEXT UNIQUE,
		applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE containers (
    id TEXT PRIMARY KEY NOT NULL,
    controller_id TEXT NOT NULL,
    name TEXT NOT NULL,
    description TEXT,
    device_type TEXT NOT NULL,
    position TEXT,
    shelf_level INTEGER,
    capacity INTEGER DEFAULT 50,
    is_active INTEGER DEFAULT 1 NOT NULL,
    metadata TEXT,
    created_at INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE stock_analysis (
    id TEXT PRIMARY KEY NOT NULL,
    image_id TEXT NOT NULL,
    controller_id TEXT NOT NULL,
    analysis_data TEXT NOT NULL,
    total_items INTEGER DEFAULT 0 NOT NULL,
    fresh_items INTEGER DEFAULT 0 NOT NULL,
    good_items INTEGER DEFAULT 0 NOT NULL,
    expired_items INTEGER DEFAULT 0 NOT NULL,
    damaged_items INTEGER DEFAULT 0 NOT NULL,
    status TEXT DEFAULT 'processing' NOT NULL,
    processing_time INTEGER,
    error_message TEXT,
    metadata TEXT,
    created_at INTEGER DEFAULT CURRENT_TIMESTAMP NOT NULL,
    processed_at INTEGER,
    FOREIGN KEY (image_id) REFERENCES "images"("id") ON UPDATE no action ON DELETE cascade,
    FOREIGN KEY (controller_id) REFERENCES "controllers"("id") ON UPDATE no action ON DELETE cascade
);
DELETE FROM sqlite_sequence;
CREATE UNIQUE INDEX "devices_mac_address_unique" ON "devices" ("mac_address");
CREATE INDEX idx_controllers_mac_address ON controllers(mac_address);
CREATE INDEX "analytics_controller_idx" ON "analytics" ("controller_id");
CREATE INDEX "analytics_metric_type_idx" ON "analytics" ("metric_type");
CREATE INDEX "analytics_recorded_at_idx" ON "analytics" ("recorded_at");
CREATE INDEX "analytics_metric_name_idx" ON "analytics" ("metric_name");
CREATE INDEX "audit_logs_user_idx" ON "audit_logs" ("user_id");
CREATE INDEX "audit_logs_entity_idx" ON "audit_logs" ("entity_type","entity_id");
CREATE INDEX "audit_logs_action_idx" ON "audit_logs" ("action");
CREATE INDEX "audit_logs_created_at_idx" ON "audit_logs" ("created_at");
CREATE INDEX "categories_name_idx" ON "categories" ("name");
CREATE INDEX "categories_parent_idx" ON "categories" ("parent_id");
CREATE INDEX "inventory_controller_product_idx" ON "inventory" ("controller_id","product_id");
CREATE INDEX "inventory_stock_level_idx" ON "inventory" ("stock_level");
CREATE INDEX "payment_methods_user_idx" ON "payment_methods" ("user_id");
CREATE INDEX "payment_methods_stripe_id_idx" ON "payment_methods" ("stripe_payment_method_id");
CREATE INDEX "payments_transaction_idx" ON "payments" ("transaction_id");
CREATE INDEX "payments_user_idx" ON "payments" ("user_id");
CREATE INDEX "payments_status_idx" ON "payments" ("status");
CREATE INDEX "payments_stripe_id_idx" ON "payments" ("stripe_payment_intent_id");
CREATE UNIQUE INDEX "products_sku_unique" ON "products" ("sku");
CREATE INDEX "products_sku_idx" ON "products" ("sku");
CREATE INDEX "products_category_idx" ON "products" ("category_id");
CREATE INDEX "products_barcode_idx" ON "products" ("barcode");
CREATE UNIQUE INDEX "sessions_qr_code_unique" ON "sessions" ("qr_code");
CREATE INDEX "sessions_qr_code_idx" ON "sessions" ("qr_code");
CREATE INDEX "sessions_controller_idx" ON "sessions" ("controller_id");
CREATE INDEX "sessions_status_idx" ON "sessions" ("status");
CREATE INDEX "sessions_expires_at_idx" ON "sessions" ("expires_at");
CREATE INDEX "transaction_items_transaction_idx" ON "transaction_items" ("transaction_id");
CREATE INDEX "transaction_items_product_idx" ON "transaction_items" ("product_id");
CREATE INDEX "transactions_session_idx" ON "transactions" ("session_id");
CREATE INDEX "transactions_user_idx" ON "transactions" ("user_id");
CREATE INDEX "transactions_controller_idx" ON "transactions" ("controller_id");
CREATE INDEX "transactions_status_idx" ON "transactions" ("status");
CREATE INDEX "transactions_created_at_idx" ON "transactions" ("created_at");
CREATE UNIQUE INDEX "users_email_unique" ON "users" ("email");
CREATE INDEX "users_email_idx" ON "users" ("email");
CREATE INDEX "users_role_idx" ON "users" ("role");
CREATE INDEX "users_external_id_idx" ON "users" ("external_id");
CREATE INDEX "vision_analysis_image_idx" ON "vision_analysis" ("image_id");
CREATE INDEX "vision_analysis_transaction_idx" ON "vision_analysis" ("transaction_id");
CREATE INDEX "vision_analysis_status_idx" ON "vision_analysis" ("status");
CREATE INDEX containers_controller_idx ON containers (controller_id);
CREATE INDEX containers_position_idx ON containers (position);
CREATE INDEX stock_analysis_image_idx ON stock_analysis (image_id);
CREATE INDEX stock_analysis_controller_idx ON stock_analysis (controller_id);
CREATE INDEX stock_analysis_status_idx ON stock_analysis (status);
CREATE INDEX stock_analysis_created_at_idx ON stock_analysis (created_at);
