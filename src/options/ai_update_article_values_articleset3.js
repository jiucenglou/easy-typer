const fs = require('fs');
const path = require('path');

// 读取 SQL 文件
try {
  const sqlFilePath = path.join('scripts', 'sqls', 'articleSet3.sql');
  const sqlContent = fs.readFileSync(sqlFilePath, 'utf8');
  
  // 使用正则表达式提取文章 ID 和内容
  const regex = /\(8, '(articleSet3-\d+)', '[^']*', "([^"]+)"/g;
  const articleMap = {};
  
  let match;
  while ((match = regex.exec(sqlContent)) !== null) {
    const articleId = match[1];
    const articleContent = match[2];
    articleMap[articleId] = articleContent;
  }
  
  // 读取 TypeScript 文件
  const tsFilePath = path.join('src', 'options', 'articleSet3.ts');
  let tsContent = fs.readFileSync(tsFilePath, 'utf8');
  
  // 替换每个文章的 value
  Object.keys(articleMap).forEach(articleId => {
    const valueRegex = new RegExp(`value: '${articleId}'`, 'g');
    tsContent = tsContent.replace(valueRegex, `value: ${JSON.stringify(articleMap[articleId])}`);
  });
  
  // 写回 TypeScript 文件
  fs.writeFileSync(tsFilePath, tsContent);
  
  console.log('articleSet3.ts 文章内容已成功更新！');
} catch (error) {
  console.error('更新文章内容时出错:', error);
}