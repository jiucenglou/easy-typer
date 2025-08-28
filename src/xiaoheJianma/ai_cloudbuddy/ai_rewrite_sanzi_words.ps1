# PowerShell script to rewrite the sanziWords.ts file with proper comma separation
try {
    # Read the existing file
    $filePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在读取文件: $filePath"
    
    $content = Get-Content -Path $filePath -Raw
    
    # Extract all words from the file using regex
    Write-Host "正在提取词条..."
    $matches = [regex]::Matches($content, "'([^']+)'")
    $words = @()
    foreach ($match in $matches) {
        $words += $match.Groups[1].Value
    }
    
    Write-Host "共提取到 $($words.Count) 个词条"
    
    # Create a new TypeScript file with proper formatting
    Write-Host "正在创建新的TypeScript文件..."
    
    # 构建新的内容，确保元素之间有逗号
    $newContent = "export const sanziWords = [\n"
    
    for ($i = 0; $i -lt $words.Count; $i++) {
        # 每10个词一行
        if ($i % 10 -eq 0) {
            if ($i -gt 0) {
                $newContent += "\n  "
            } else {
                $newContent += "  "
            }
        }
        
        # 添加词条，带单引号
        $newContent += "'$($words[$i])'"
        
        # 如果不是最后一个元素，添加逗号
        if ($i -lt $words.Count - 1) {
            $newContent += ", "
        }
    }
    
    $newContent += "\n];"
    
    # Write the new content to the file
    Write-Host "正在保存文件..."
    [System.IO.File]::WriteAllText($filePath, $newContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "完成！已重写文件，并在数组元素之间添加了逗号。"
} catch {
    Write-Host "错误: $_"
}