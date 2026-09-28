const fs = require("fs");
const path = require("path");
let stripComments;

try {
  stripComments = require("strip-comments");
} catch (e) {
  console.error(
    "Please run this script from web/ directory where strip-comments is installed, or install it.",
  );
}

function stripLuaComments(code) {
  let out = "";
  let i = 0;
  while (i < code.length) {
    if (code[i] === '"' || code[i] === "'") {
      let quote = code[i];
      out += code[i++];
      while (i < code.length) {
        if (code[i] === "\\") {
          out += code[i++];
          if (i < code.length) out += code[i++];
        } else if (code[i] === quote) {
          out += code[i++];
          break;
        } else {
          out += code[i++];
        }
      }
    } else if (code.startsWith("--[[", i)) {
      let end = code.indexOf("]]", i + 4);
      if (end === -1) end = code.length;
      else end += 2;
      i = end;
    } else if (code.startsWith("--", i)) {
      let end = code.indexOf("\n", i + 2);
      if (end === -1) end = code.length;
      i = end;
    } else {
      out += code[i++];
    }
  }
  return out;
}

const rootDir = "d:/txData/QBCore_C6A9AA.base/resources/xeno-adminmenu";
const excludeDirs = ["node_modules", ".git", "build", "dist"];

function processDir(dir) {
  const files = fs.readdirSync(dir);
  for (const file of files) {
    const fullPath = path.join(dir, file);
    if (fs.statSync(fullPath).isDirectory()) {
      if (!excludeDirs.includes(file)) {
        processDir(fullPath);
      }
    } else {
      const ext = path.extname(file);
      let content = fs.readFileSync(fullPath, "utf8");
      let newContent = content;

      if (ext === ".lua") {
        newContent = stripLuaComments(content);
      } else if ([".js", ".ts", ".jsx", ".tsx", ".css"].includes(ext)) {
        if (stripComments) {
          try {
            newContent = stripComments(content);
            // strip-comments sometimes leaves empty lines for single line comments, we can clean them up if we want, but it's safe to just leave them or trim.
          } catch (e) {
            console.error("Error stripping comments from " + fullPath, e);
          }
        }
      }

      if (newContent !== content) {
        fs.writeFileSync(fullPath, newContent, "utf8");
        console.log(`Stripped comments from ${fullPath}`);
      }
    }
  }
}

processDir(rootDir);
