# PowerShell script to add commas between array elements
try {
    # Read the existing file
    $filePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在读取文件: $filePath"
    
    $content = Get-Content -Path $filePath -Raw
    
    # Replace spaces between single quotes with commas
    Write-Host "正在添加逗号..."
    
    # 使用正则表达式在单引号之间添加逗号
    $newContent = $content -replace "' '", "', '"
    
    # Write the modified content back to the file
    Write-Host "正在保存修改后的文件..."
    Set-Content -Path $filePath -Value $newContent -Encoding UTF8
    
    Write-Host "完成！已在数组元素之间添加逗号。"
} catch {
    Write-Host "错误: $_"
}