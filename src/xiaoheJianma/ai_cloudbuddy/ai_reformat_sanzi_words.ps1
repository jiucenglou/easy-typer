# 重新格式化sanziWords.ts文件，使每个元素占一行

# 读取原始文件内容
$filePath = "src/xiaoheJianma/sanziWords.ts"
$content = Get-Content -Path $filePath -Raw

# 提取数组内容
$startPattern = "export const sanziWords: string\[\] = \["
$endPattern = "\]"

$startIndex = $content.IndexOf($startPattern) + $startPattern.Length
$endIndex = $content.IndexOf($endPattern, $startIndex)
$arrayContent = $content.Substring($startIndex, $endIndex - $startIndex)

# 分割所有元素
$elements = $arrayContent -split "'" | Where-Object { $_ -match "[^\s,]" } | ForEach-Object { $_.Trim("', \n\r\t") } | Where-Object { $_ -ne "" }

# 重新格式化数组，每个元素一行
$newArrayContent = "`n"
foreach ($element in $elements) {
    $newArrayContent += "  '$element',`n"
}
# 移除最后一个逗号
$newArrayContent = $newArrayContent.TrimEnd(",`n") + "`n"

# 构建新的文件内容
$newContent = $content.Substring(0, $startIndex) + $newArrayContent + $content.Substring($endIndex)

# 写入文件
$newContent | Out-File -FilePath $filePath -Encoding utf8

Write-Host "文件已成功重新格式化，每个元素现在占一行。"