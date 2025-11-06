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
const configContent = `module.exports = {
  apps: [
    {
      name: '${appName}',
      cwd: '${cwdEscaped}',
      script: 'npm',
      args: 'run start',
      interpreter: 'none',
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
