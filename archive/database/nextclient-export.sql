PRAGMA defer_foreign_keys=TRUE;
CREATE TABLE IF NOT EXISTS "__drizzle_migrations" (
			id SERIAL PRIMARY KEY,
			hash text NOT NULL,
			created_at numeric
		);
INSERT INTO __drizzle_migrations VALUES(NULL,'8c071da48029ad628d380d6a8fef3ce8cb46389b9f150c318b5197b857e163eb',1750254655598);
CREATE TABLE `payment_methods` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`stripe_payment_method_id` text NOT NULL,
	`type` text NOT NULL,
	`brand` text,
	`last_four` text,
	`expiry_month` integer,
	`expiry_year` integer,
	`is_default` integer DEFAULT false NOT NULL,
	`is_active` integer DEFAULT true NOT NULL,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE `payments` (
	`id` text PRIMARY KEY NOT NULL,
	`user_id` text NOT NULL,
	`session_id` text,
	`payment_method_id` text,
	`stripe_payment_intent_id` text,
	`amount` real NOT NULL,
	`currency` text DEFAULT 'USD' NOT NULL,
	`status` text DEFAULT 'pending' NOT NULL,
	`description` text,
	`metadata` text,
	`created_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	`updated_at` integer DEFAULT CURRENT_TIMESTAMP NOT NULL,
	FOREIGN KEY (`payment_method_id`) REFERENCES `payment_methods`(`id`) ON UPDATE no action ON DELETE no action
);
CREATE TABLE `users` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`email` text NOT NULL,
	`role` text DEFAULT 'USER' NOT NULL,
	`external_id` text,
	`phone_number` text,
	`is_active` integer DEFAULT 1 NOT NULL,
	`last_login_at` integer,
	`created_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
	`updated_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL
);
CREATE TABLE d1_migrations(
		id         INTEGER PRIMARY KEY AUTOINCREMENT,
		name       TEXT UNIQUE,
		applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);
CREATE TABLE `controllers` (
	`id` text PRIMARY KEY NOT NULL,
	`name` text NOT NULL,
	`location` text NOT NULL,
	`status` text DEFAULT 'offline' NOT NULL,
	`ip_address` text,
	`mac_address` text,
	`firmware_version` text,
	`capabilities` text,
	`max_devices` integer DEFAULT 10 NOT NULL,
	`current_devices` integer DEFAULT 0 NOT NULL,
	`last_seen` integer,
	`last_heartbeat` integer,
	`metadata` text,
	`created_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
	`updated_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL
);
CREATE TABLE `cameras` (
	`id` text PRIMARY KEY NOT NULL,
	`controller_id` text NOT NULL,
	`device_id` text,
	`name` text NOT NULL,
	`type` text DEFAULT 'esp32-cam' NOT NULL,
	`status` text DEFAULT 'offline' NOT NULL,
	`resolution` text DEFAULT '640x480',
	`frame_rate` integer DEFAULT 10,
	`stream_url` text,
	`recording_enabled` integer DEFAULT 0,
	`motion_detection` integer DEFAULT 1,
	`last_image` text,
	`last_capture` integer,
	`total_captures` integer DEFAULT 0,
	`metadata` text,
	`created_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL,
	`updated_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL
);
CREATE TABLE `captured_images` (
	`id` text PRIMARY KEY NOT NULL,
	`camera_id` text NOT NULL,
	`controller_id` text NOT NULL,
	`device_id` text,
	`filename` text NOT NULL,
	`url` text,
	`local_path` text,
	`size` integer,
	`width` integer,
	`height` integer,
	`format` text DEFAULT 'jpeg',
	`capture_type` text DEFAULT 'manual',
	`metadata` text,
	`is_processed` integer DEFAULT 0,
	`processed_at` integer,
	`created_at` integer DEFAULT (CURRENT_TIMESTAMP) NOT NULL
);
DELETE FROM sqlite_sequence;
CREATE INDEX `payment_methods_user_idx` ON `payment_methods` (`user_id`);
CREATE INDEX `payment_methods_stripe_idx` ON `payment_methods` (`stripe_payment_method_id`);
CREATE INDEX `payments_user_idx` ON `payments` (`user_id`);
CREATE INDEX `payments_status_idx` ON `payments` (`status`);
CREATE INDEX `payments_stripe_id_idx` ON `payments` (`stripe_payment_intent_id`);
CREATE INDEX `users_external_id_idx` ON `users` (`external_id`);
CREATE INDEX `users_role_idx` ON `users` (`role`);
CREATE INDEX `users_email_idx` ON `users` (`email`);
CREATE UNIQUE INDEX `users_email_unique` ON `users` (`email`);
CREATE INDEX `controllers_status_idx` ON `controllers` (`status`);
CREATE INDEX `controllers_location_idx` ON `controllers` (`location`);
CREATE INDEX `controllers_last_seen_idx` ON `controllers` (`last_seen`);
CREATE INDEX `controllers_mac_address_idx` ON `controllers` (`mac_address`);
CREATE INDEX `cameras_controller_idx` ON `cameras` (`controller_id`);
CREATE INDEX `cameras_device_idx` ON `cameras` (`device_id`);
CREATE INDEX `cameras_status_idx` ON `cameras` (`status`);
CREATE INDEX `cameras_last_capture_idx` ON `cameras` (`last_capture`);
CREATE INDEX `captured_images_camera_idx` ON `captured_images` (`camera_id`);
CREATE INDEX `captured_images_controller_idx` ON `captured_images` (`controller_id`);
CREATE INDEX `captured_images_device_idx` ON `captured_images` (`device_id`);
CREATE INDEX `captured_images_capture_type_idx` ON `captured_images` (`capture_type`);
CREATE INDEX `captured_images_created_at_idx` ON `captured_images` (`created_at`);
