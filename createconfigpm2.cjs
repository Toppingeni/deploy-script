// createconfigpm2.cjs — gen ecosystem.config.cjs พร้อม env block (PORT contract — plan §4A/§5)
// Usage: node createconfigpm2.cjs <appName> <destination-path> [entryScript]
// env ที่ inject: PORT / APP_BASE_PATH / PUBLIC_BASE_URL (อ่านจาก env var ของ step ที่เรียก)
const fs = require("fs");
const path = require("path");

const appName = process.argv[2];
const destination = process.argv[3];
const entryArg = process.argv[4];

if (!appName || !destination) {
  console.error(
    "Usage: node createconfigpm2.cjs <appName> <destination-path> [entryScript]",
  );
  process.exit(1);
}

fs.mkdirSync(destination, { recursive: true });
fs.mkdirSync(path.join(destination, "logs"), { recursive: true });

// auto-detect entry point (ตามลำดับเดียวกับ deploy.bat) ถ้าไม่ส่ง arg มา
function detectEntry() {
  const candidates = [
    "build\\server.js",
    "build\\index.js",
    "dist\\server\\node-build.mjs",
  ];
  for (const c of candidates) {
    if (fs.existsSync(path.join(destination, c))) return c;
  }
  return candidates[candidates.length - 1];
}
const entry = entryArg || detectEntry();

// PORT มาจาก registry เท่านั้น (ห้าม fallback เงียบๆ — port ผิด = ชนกัน)
const port = process.env.ALLOC_PORT || process.env.PORT;
if (!port) {
  console.error(
    "[ERROR] ALLOC_PORT/PORT not set — ต้องได้ค่าจาก deploy registry (Get-OrAllocatePort)",
  );
  process.exit(1);
}
const appBasePath = process.env.APP_BASE_PATH || "";
const publicBaseUrl = process.env.PUBLIC_BASE_URL || "";

const cwdEscaped = destination.replace(/\\/g, "\\\\");
const entryEscaped = entry.replace(/\\/g, "\\\\");

const configContent = `module.exports = {
  apps: [
    {
      name: '${appName}',
      cwd: '${cwdEscaped}',
      script: '${entryEscaped}',
      interpreter: 'node',
      instances: 1,
      exec_mode: 'fork',
      out_file: 'logs/out.log',
      error_file: 'logs/error.log',
      time: true,
      env: {
        PORT: '${port}',
        APP_BASE_PATH: '${appBasePath}',
        PUBLIC_BASE_URL: '${publicBaseUrl}',
      },
    },
  ],
};
`;

const outputPath = path.join(destination, "ecosystem.config.cjs");
fs.writeFileSync(outputPath, configContent, "utf8");

console.log(
  `[OK] Generated ${outputPath} for app "${appName}" (PORT=${port}, entry=${entry})`,
);
