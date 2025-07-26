const jwt = require("jsonwebtoken");
const secret = "MySecretKey123!!";

// Test with the exact same payload format as the Next.js client
const token = jwt.sign(
  {
    sub: "test-user-id",
    email: "test@example.com",
    name: "Test User",
    role: "ADMIN", // Use ADMIN role to match BridgeServer expectations
    iat: Math.floor(Date.now() / 1000),
    exp: Math.floor(Date.now() / 1000) + 60 * 15, // 15 minutes
    iss: "delicasa-bridge-proxy",
    aud: "bridgeserver.delicasa.workers.dev",
  },
  secret
);

console.log("Token:", token);
console.log("Secret used:", secret);
