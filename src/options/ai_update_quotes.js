const fs = require('fs');
const path = require('path');

// 要修复的文件列表
const filesToFix = [
  'articleSet1.ts',
  'articleSet2.ts',
  'articleSet3.ts',
  'articleSet4.ts'
];

// 遍历文件并修复双引号
filesToFix.forEach(fileName => {
  try {
    const filePath = path.join('src', 'options', fileName);
    
    // 读取文件内容
    let content = fs.readFileSync(filePath, 'utf8');
    
    // 查找并替换 value: "xxx" 模式中的双引号为单引号
    const regex = /value: "([^"]*)"/g;
    content = content.replace(regex, 'value: \'$1\'');
    
    // 写回文件
    fs.writeFileSync(filePath, content);
    
    console.log(`成功修复 ${fileName} 中的双引号问题`);
  } catch (error) {
    console.error(`修复 ${fileName} 时出错:`, error);
  }
});

console.log('所有文件修复完成！');