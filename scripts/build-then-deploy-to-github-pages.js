const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 文件路径
const vueConfigPath = path.join('vue.config.js');

// 读取原始文件内容
console.log('读取vue.config.js文件...');
const originalVueConfig = fs.readFileSync(vueConfigPath, 'utf8');

try {
  // 修改publicPath为GitHub Pages路径
  console.log('修改publicPath为GitHub Pages路径...');
  const modifiedVueConfig = originalVueConfig.replace(
    /publicPath: process\.env\.NODE_ENV === 'production'[\s\S]*?\? ['"].*['"][\s\S]*?: ['"]\/['"]/,
    "publicPath: process.env.NODE_ENV === 'production'\n    ? '/easy-typer/'\n    : '/'"
  );
 
  // 写入修改后的内容
  fs.writeFileSync(vueConfigPath, modifiedVueConfig);
  console.log('已将vue.config.js配置修改为GitHub Pages部署模式');
  
  // 构建GitHub Pages版本
  console.log('开始构建GitHub Pages版本...');
  console.log('运行 yarn build...');
  execSync('yarn build', { stdio: 'inherit' });
  
  // 部署到GitHub Pages
  console.log('部署到GitHub Pages...');
  execSync('yarn deploy', { stdio: 'inherit' });
  console.log('GitHub Pages部署完成！');
  
  // 恢复vue.config.js原始配置
  console.log('恢复vue.config.js原始配置...');
  fs.writeFileSync(vueConfigPath, originalVueConfig);
  console.log('已恢复vue.config.js到原始状态');
  
  console.log('GitHub Pages部署完成！');
  console.log('网站已部署到 https://jiucenglou.github.io/easy-typer/');
  
} catch (error) {
  // 如果出错，恢复原始文件内容
  console.error('部署到GitHub Pages过程中出错:', error);
  fs.writeFileSync(vueConfigPath, originalVueConfig);
  console.log('已恢复vue.config.js文件到原始状态');
  process.exit(1);
}