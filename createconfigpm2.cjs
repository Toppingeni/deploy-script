// createconfigpm2.js
const fs = require("fs");
const path = require("path");

// รับ argument จาก command line
// arg[2] = appName, arg[3] = destination
const appName = process.argv[2];
const destination = process.argv[3];

if (!appName || !destination) {
  console.error("Usage: node createconfigpm2.js <appName> <destination-path>");
  process.exit(1);
}

// สร้างโฟลเดอร์ปลายทาง (ถ้ายังไม่มี)
fs.mkdirSync(destination, { recursive: true });

// สร้างโฟลเดอร์ logs
const logsDir = path.join(destination, "logs");
fs.mkdirSync(logsDir, { recursive: true });

// escape backslash สำหรับ JS string
const cwdEscaped = destination.replace(/\\/g, "\\\\");

// เนื้อไฟล์ ecosystem.config.js
// Forward slashes in script path: a single-quoted 'dist\server\...' makes Node
// interpret \s and \n as escapes (→ "distserver" + newline) and pm2 can't find it.
// Forward slashes work on Windows and sidestep the escaping entirely.
// env_file + NODE_ENV mirror the proven hand-written config so the app loads .env
// and serves its production SPA build.
const configContent = `module.exports = {
  apps: [
    {
      name: '${appName}',
      cwd: '${cwdEscaped}',
      script: 'dist/server/node-build.mjs',
      interpreter: 'node',
      env_file: '.env',
      env: {
        NODE_ENV: 'production',
      },
      instances: 1,
      exec_mode: 'fork',
      out_file: 'logs/out.log',
      error_file: 'logs/error.log',
      time: true,
    },
  ],
};
`;

// เขียนไฟล์ config
const outputPath = path.join(destination, "ecosystem.config.cjs");
fs.writeFileSync(outputPath, configContent, "utf8");

console.log(`[OK] Generated ${outputPath} for app "${appName}"`);
