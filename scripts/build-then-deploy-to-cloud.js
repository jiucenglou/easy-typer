const fs = require('fs');
const path = require('path');
const { execSync } = require('child_process');

// 确保vue.config.js配置正确
const vueConfigPath = path.join('vue.config.js');
const vueConfig = fs.readFileSync(vueConfigPath, 'utf8');

try {
  // 检查并确保publicPath和outputDir配置正确
  let updatedConfig = vueConfig;
  let configChanged = false;
  
  // 检查publicPath配置
  const expectedPublicPath = "publicPath: process.env.NODE_ENV === 'production'\n    ? './'\n    : '/'";
  if (!vueConfig.includes(expectedPublicPath)) {
    console.log('修改publicPath为腾讯云部署配置...');
    updatedConfig = updatedConfig.replace(
      /publicPath: process\.env\.NODE_ENV === 'production'[\s\S]*?\? ['"].*['"][\s\S]*?: ['"]\/['"]/,
      "publicPath: process.env.NODE_ENV === 'production'\n    ? './'\n    : '/'"
    );
    configChanged = true;
  }
  
  // 检查outputDir配置
  if (!vueConfig.includes("outputDir: 'docs',")) {
    console.log('修改outputDir为docs...');
    updatedConfig = updatedConfig.replace(
      /outputDir: ['"].*['"],/,
      "outputDir: 'docs',"
    );
    configChanged = true;
  }
  
  // 如果配置有变化，写入更新后的配置
  if (configChanged) {
    fs.writeFileSync(vueConfigPath, updatedConfig);
    console.log('已更新vue.config.js配置为腾讯云部署模式');
  }
  
  // 构建Web应用
  console.log('开始构建Web应用...');
  console.log('运行 yarn build...');
  execSync('yarn build', { stdio: 'inherit' });
  console.log('Web应用构建完成！');
  
  // 上传到腾讯云主机
  console.log('开始上传到腾讯云主机...');
  console.log('运行 scp 命令将文件复制到腾讯云主机...');
  execSync('scp -r docs/* 腾讯云:~/Downloads/docs/', { stdio: 'inherit' });
  console.log('设置正确的文件权限...');
  execSync('ssh 腾讯云 "chmod -R 755 ~/Downloads/docs/"', { stdio: 'inherit' });
  
  console.log('通过 SSH 将文件部署到网站目录...');
  execSync('ssh 腾讯云 "sudo cp -r ~/Downloads/docs/* /var/www/html/"', { stdio: 'inherit' });
  console.log('腾讯云主机部署完成！');
  
} catch (error) {
  console.error('部署到腾讯云主机过程中出错:', error);
  process.exit(1);
}