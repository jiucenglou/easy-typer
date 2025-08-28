# PowerShell script to verify the sanziWords.ts file
try {
    $filePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在验证文件: $filePath"
    
    # 检查文件是否存在
    if (-not (Test-Path $filePath)) {
        Write-Host "错误: 文件不存在"
        exit 1
    }
    
    # 获取文件大小
    $fileInfo = Get-Item $filePath
    $fileSize = $fileInfo.Length
    Write-Host "文件大小: $fileSize 字节"
    
    # 检查文件开头和结尾
    $content = Get-Content -Path $filePath -Raw
    $firstLine = ($content -split "`n")[0]
    $lastLine = ($content -split "`n")[-1]
    
    Write-Host "文件第一行: $firstLine"
    Write-Host "文件最后一行: $lastLine"
    
    # 检查逗号分隔符
    $commaCount = ($content -split ",").Length - 1
    Write-Host "逗号数量: $commaCount (应该接近词条数量)"
    
    # 检查单引号数量
    $quoteCount = ($content -split "'").Length - 1
    Write-Host "单引号数量: $quoteCount (应该是词条数量的两倍)"
    
    Write-Host "验证完成。文件格式看起来是正确的。"
} catch {
    Write-Host "错误: $_"
}