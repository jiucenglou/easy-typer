# PowerShell script to fix the sanziWords.ts file with proper comma separation
try {
    # Read the existing file
    $filePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在读取文件: $filePath"
    
    $content = Get-Content -Path $filePath -Raw
    
    # Replace spaces between single quotes with comma+space
    Write-Host "正在添加逗号..."
    
    # 使用正则表达式替换单引号后面跟着空格再跟着单引号的模式
    $pattern = "' '"
    $replacement = "', '"
    $newContent = $content -replace $pattern, $replacement
    
    # Write the modified content back to the file
    Write-Host "正在保存修改后的文件..."
    Set-Content -Path $filePath -Value $newContent -Encoding UTF8
    
    # Verify the change
    $updatedContent = Get-Content -Path $filePath -Raw
    $sample = $updatedContent.Substring(0, [Math]::Min(200, $updatedContent.Length))
    Write-Host "修改后的文件开头:"
    Write-Host $sample
    
    Write-Host "完成！已在数组元素之间添加逗号。"
} catch {
    Write-Host "错误: $_"
}