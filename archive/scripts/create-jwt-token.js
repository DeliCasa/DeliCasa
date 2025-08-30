#!/usr/bin/env node

/**
 * 🔐 JWT TOKEN GENERATOR FOR DELICASA BRIDGE SERVER
 * 
 * Creates a valid JWT token that matches the expected format
 * for production authentication testing
 */

const crypto = require('crypto');

// JWT Secret from .env (matches BRIDGE_SERVER_JWT_SECRET)
const JWT_SECRET = 'MySecretKey123!!';

// Create JWT header
const header = {
  alg: 'HS256',
  typ: 'JWT'
};

// Create JWT payload with admin role
const payload = {
  sub: 'test-admin-user',
  email: 'admin@delicasa.net.br',
  name: 'Test Admin User',
  role: 'ADMIN',
  iat: Math.floor(Date.now() / 1000),
  exp: Math.floor(Date.now() / 1000) + (60 * 60), // 1 hour expiry
  iss: 'delicasa-bridge-proxy',
  aud: 'delicasa-bridge-server'
};

// Base64URL encode function
function base64URLEncode(obj) {
  const jsonStr = typeof obj === 'string' ? obj : JSON.stringify(obj);
  return Buffer.from(jsonStr)
    .toString('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

// Create HMAC-SHA256 signature
function createSignature(data, secret) {
  return crypto
    .createHmac('sha256', secret)
    .update(data)
    .digest('base64')
    .replace(/\+/g, '-')
    .replace(/\//g, '_')
    .replace(/=/g, '');
}

// Generate JWT
const headerEncoded = base64URLEncode(header);
const payloadEncoded = base64URLEncode(payload);
const signatureData = `${headerEncoded}.${payloadEncoded}`;
const signature = createSignature(signatureData, JWT_SECRET);

const jwt = `${headerEncoded}.${payloadEncoded}.${signature}`;

console.log('🔐 Generated JWT Token for DeliCasa Bridge Server');
console.log('================================================');
console.log('📊 Payload:', JSON.stringify(payload, null, 2));
console.log('🎫 JWT Token:', jwt);
console.log('📏 Length:', jwt.length, 'characters');
console.log('⏰ Expires:', new Date(payload.exp * 1000).toISOString());
console.log('================================================');
console.log('✅ Ready to use with Authorization: Bearer', jwt);

// Save token to file for easy access
const fs = require('fs');
fs.writeFileSync('jwt-token.txt', jwt);
console.log('💾 Token saved to jwt-token.txt');