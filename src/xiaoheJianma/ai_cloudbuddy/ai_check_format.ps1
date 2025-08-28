# PowerShell script to check the format of sanziWords.ts
try {
    # Read the first 100 characters of the file
    $filePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在检查文件格式: $filePath"
    
    $fileContent = Get-Content -Path $filePath -Raw
    $firstPart = $fileContent.Substring(0, [Math]::Min(100, $fileContent.Length))
    Write-Host "文件开头 (前100个字符):"
    Write-Host $firstPart
    
    # Check if commas are present between elements
    $hasCommas = $fileContent -match "'[^']+', "
    Write-Host "文件中是否包含逗号分隔的元素: $hasCommas"
    
    # Count occurrences of commas between elements
    $commaCount = ([regex]::Matches($fileContent, "'[^']+', ")).Count
    Write-Host "逗号分隔符数量: $commaCount"
    
    # Count occurrences of single quotes (should be approximately 2 * number of words)
    $quoteCount = ([regex]::Matches($fileContent, "'")).Count
    Write-Host "单引号数量: $quoteCount (应该接近词条数量的两倍)"
    
    Write-Host "检查完成。"
} catch {
    Write-Host "错误: $_"
}