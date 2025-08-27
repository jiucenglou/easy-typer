const { execSync } = require('child_process');
const path = require('path');
const readline = require('readline');

const rl = readline.createInterface({
  input: process.stdin,
  output: process.stdout
});

// 定义脚本路径
const buildElectronScript = path.join(__dirname, 'build-electron.js');
const deployToCloudScript = path.join(__dirname, 'build-then-deploy-to-cloud.js');
const deployToGithubPagesScript = path.join(__dirname, 'build-then-deploy-to-github-pages.js');

// 显示菜单
console.log('=== 构建与部署菜单 ===');
console.log('1. 构建Electron应用');
console.log('2. 部署到腾讯云主机');
console.log('3. 部署到GitHub Pages');
console.log('4. 执行所有操作（按顺序）');
console.log('0. 退出');

rl.question('请选择要执行的操作 [0-4]: ', (answer) => {
  switch (answer.trim()) {
    case '1':
      console.log('\n=== 开始构建Electron应用 ===');
      try {
        execSync(`node "${buildElectronScript}"`, { stdio: 'inherit' });
        console.log('=== Electron应用构建完成 ===');
      } catch (error) {
        console.error('构建Electron应用失败:', error.message);
      }
      break;
      
    case '2':
      console.log('\n=== 开始部署到腾讯云主机 ===');
      try {
        execSync(`node "${deployToCloudScript}"`, { stdio: 'inherit' });
        console.log('=== 腾讯云主机部署完成 ===');
      } catch (error) {
        console.error('部署到腾讯云主机失败:', error.message);
      }
      break;
      
    case '3':
      console.log('\n=== 开始部署到GitHub Pages ===');
      try {
        execSync(`node "${deployToGithubPagesScript}"`, { stdio: 'inherit' });
        console.log('=== GitHub Pages部署完成 ===');
      } catch (error) {
        console.error('部署到GitHub Pages失败:', error.message);
      }
      break;
      
    case '4':
      console.log('\n=== 开始执行所有操作 ===');
      
      // 构建Electron应用
      console.log('\n=== 步骤1: 构建Electron应用 ===');
      try {
        execSync(`node "${buildElectronScript}"`, { stdio: 'inherit' });
        console.log('=== Electron应用构建完成 ===');
        
        // 部署到腾讯云主机
        console.log('\n=== 步骤2: 部署到腾讯云主机 ===');
        execSync(`node "${deployToCloudScript}"`, { stdio: 'inherit' });
        console.log('=== 腾讯云主机部署完成 ===');
        
        // 部署到GitHub Pages
        console.log('\n=== 步骤3: 部署到GitHub Pages ===');
        execSync(`node "${deployToGithubPagesScript}"`, { stdio: 'inherit' });
        console.log('=== GitHub Pages部署完成 ===');
        
        console.log('\n=== 所有操作已成功完成 ===');
      } catch (error) {
        console.error('执行过程中出错:', error.message);
      }
      break;
      
    case '0':
      console.log('退出程序');
      break;
      
    default:
      console.log('无效的选择，请输入0-4之间的数字');
  }
  
  rl.close();
});