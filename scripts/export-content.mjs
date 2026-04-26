import { createHash } from "node:crypto";
import { mkdir, readFile, writeFile } from "node:fs/promises";
import path from "node:path";
import { fileURLToPath } from "node:url";

const rootDirectory = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const contentSourcePath = path.join(rootDirectory, "data", "content.json");
const publicContentDirectory = path.join(rootDirectory, "public", "content");

const rawContent = await readFile(contentSourcePath, "utf8");
const contentBundle = JSON.parse(rawContent);
const formattedContent = `${JSON.stringify(contentBundle, null, 2)}\n`;
const contentBytes = Buffer.from(formattedContent);
const contentHash = createHash("sha256").update(contentBytes).digest("hex");

const manifest = {
  schemaVersion: contentBundle.schemaVersion,
  contentVersion: contentBundle.contentVersion,
  generatedAt: contentBundle.generatedAt,
  minAppVersion: contentBundle.minAppVersion,
  bundle: {
    url: "/content/content.json",
    sha256: contentHash,
    bytes: contentBytes.byteLength
  }
};

await mkdir(publicContentDirectory, { recursive: true });
await writeFile(path.join(publicContentDirectory, "content.json"), formattedContent);
await writeFile(path.join(publicContentDirectory, "manifest.json"), `${JSON.stringify(manifest, null, 2)}\n`);

console.log(`Exported ${contentBundle.cheatSheets.length} chapters to public/content.`);
