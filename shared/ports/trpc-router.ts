/**
 * Shared tRPC Router Types
 * 
 * This file provides shared type definitions for tRPC router
 * to ensure type safety between BridgeServer and next-client
 */

import { z } from "zod";

// ========================================
// Health Router Types
// ========================================

export const HealthCheckOutputSchema = z.object({
  status: z.enum(["OK", "FAIL"]),
  time: z.string(),
  db: z.boolean(),
  r2: z.boolean(),
  uptime: z.number().optional(),
});

export const DetailedHealthOutputSchema = z.object({
  status: z.enum(["OK", "FAIL"]),
  time: z.string(),
  db: z.boolean(),
  r2: z.boolean(),
  services: z.object({
    database: z.object({
      status: z.enum(["connected", "disconnected", "error"]),
      responseTime: z.number().optional(),
    }),
    cache: z.object({
      status: z.enum(["connected", "disconnected", "error"]),
      responseTime: z.number().optional(),
    }).optional(),
  }),
  version: z.string(),
  uptime: z.number(),
});

// ========================================
// Controller Router Types  
// ========================================

export const ControllerListInputSchema = z.object({
  limit: z.number().min(1).max(100).default(20).optional(),
  offset: z.number().min(0).default(0).optional(),
  status: z.enum(["online", "offline", "maintenance", "error", "configuring"]).optional(),
});

export const ControllerOutputSchema = z.object({
  id: z.string(),
  name: z.string(),
  description: z.string().nullable(),
  status: z.enum(["online", "offline", "maintenance", "error", "configuring"]),
  ipAddress: z.string().nullable(),
  macAddress: z.string().nullable(),
  serialNumber: z.string().nullable(),
  hardwareSignature: z.string().nullable(),
  apiEndpoint: z.string().nullable(),
  deviceType: z.string(),
  connectionType: z.string(),
  capabilities: z.array(z.string()),
  osInfo: z.string().nullable(),
  token: z.string().nullable(),
  lastSeen: z.string(),
  location: z.string().nullable(),
  coordinates: z.object({
    latitude: z.number(),
    longitude: z.number(),
  }).nullable(),
  createdAt: z.string(),
  updatedAt: z.string(),
});

export const ControllerListOutputSchema = z.object({
  controllers: z.array(ControllerOutputSchema),
  total: z.number(),
  hasMore: z.boolean(),
});

export const ControllerDetailOutputSchema = ControllerOutputSchema.extend({
  cameras: z.array(z.object({
    id: z.string(),
    name: z.string(),
    status: z.enum(["online", "offline", "maintenance", "error"]),
  })).optional(),
});

export const UpdateControllerStatusInputSchema = z.object({
  id: z.string(),
  status: z.enum(["online", "offline", "maintenance", "error", "configuring"]),
});

export const UpdateControllerStatusOutputSchema = z.object({
  success: z.boolean(),
  message: z.string(),
});

// ========================================
// Type Inference
// ========================================

export type HealthCheckOutput = z.infer<typeof HealthCheckOutputSchema>;
export type DetailedHealthOutput = z.infer<typeof DetailedHealthOutputSchema>;
export type ControllerListInput = z.infer<typeof ControllerListInputSchema>;
export type ControllerOutput = z.infer<typeof ControllerOutputSchema>;
export type ControllerListOutput = z.infer<typeof ControllerListOutputSchema>;
export type ControllerDetailOutput = z.infer<typeof ControllerDetailOutputSchema>;
export type UpdateControllerStatusInput = z.infer<typeof UpdateControllerStatusInputSchema>;
export type UpdateControllerStatusOutput = z.infer<typeof UpdateControllerStatusOutputSchema>;

// ========================================
// AppRouter Type Declaration
// ========================================

/**
 * AppRouter type declaration that matches BridgeServer implementation
 * This will be augmented with proper tRPC types in the client setup
 */
export type AppRouter = any;