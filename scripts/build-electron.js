const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 文件路径
const easyTyperPath = path.join('src', 'api', 'easyTyper.ts');

// 读取原始文件内容
console.log('读取easyTyper.ts文件...');
const originalContent = fs.readFileSync(easyTyperPath, 'utf8');

try {
  // 步骤1: 修改baseURL为绝对地址
  console.log('修改baseURL为绝对地址...');
  let modifiedContent = originalContent.replace(
    "baseURL: '/',",
    "// baseURL: '/',\n  baseURL: 'https://typer.owenyang.top',"
  );
  
  // 同时注释掉原来的注释行，避免重复
  modifiedContent = modifiedContent.replace(
    "// baseURL: 'https://typer.owenyang.top', // 运行 yarn build 和 yarn dist 创建 electron 打包之前, 需要把 baseURL 换成绝对地址",
    "// 已修改为绝对地址用于electron打包"
  );
  
  // 写入修改后的内容
  fs.writeFileSync(easyTyperPath, modifiedContent);
  console.log('已将baseURL修改为绝对地址');
  
  // 步骤2: 运行yarn build和yarn dist构建electron打包
  console.log('开始构建electron应用...');
  console.log('运行 yarn build...');
  execSync('yarn build', { stdio: 'inherit' });
  
  console.log('运行 yarn dist...');
  execSync('yarn dist', { stdio: 'inherit' });
  console.log('electron打包构建完成！');
  
  // 步骤3: 修改baseURL回相对地址
  console.log('修改baseURL回相对地址...');
  let restoredContent = modifiedContent.replace(
    "// baseURL: '/',\n  baseURL: 'https://typer.owenyang.top',",
    "baseURL: '/',"
  );
  
  // 恢复注释行
  restoredContent = restoredContent.replace(
    "// 已修改为绝对地址用于electron打包",
    "// baseURL: 'https://typer.owenyang.top', // 运行 yarn build 和 yarn dist 创建 electron 打包之前, 需要把 baseURL 换成绝对地址"
  );
  
  // 写入恢复后的内容
  fs.writeFileSync(easyTyperPath, restoredContent);
  console.log('已将baseURL修改回相对地址');
  
  console.log('Electron打包完成！');
  console.log('electron打包位于dist目录');
  
} catch (error) {
  // 如果出错，恢复原始文件内容
  console.error('构建过程中出错:', error);
  fs.writeFileSync(easyTyperPath, originalContent);
  console.log('已恢复easyTyper.ts文件到原始状态');
  process.exit(1);
}