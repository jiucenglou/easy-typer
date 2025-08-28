# 读取Excel文件中的四字词条并生成TypeScript文件

# 检查是否安装了ImportExcel模块
if (-not (Get-Module -ListAvailable -Name ImportExcel)) {
    Write-Host "ImportExcel模块未安装，正在安装..."
    Install-Module -Name ImportExcel -Scope CurrentUser -Force
}

# 导入ImportExcel模块
Import-Module ImportExcel

# 定义文件路径
$excelPath = "src/xiaoheJianma/微软五笔挂接小鹤音形码表-四字及以上词条.xlsx"
$tsPath = "src/xiaoheJianma/siziWords.ts"

# 检查Excel文件是否存在
if (-not (Test-Path $excelPath)) {
    Write-Host "Excel文件不存在: $excelPath"
    exit 1
}

# 读取Excel文件
Write-Host "正在读取Excel文件: $excelPath"
$excelData = Import-Excel -Path $excelPath

# 提取汉字词条（第二列）
$words = @()
foreach ($row in $excelData) {
    # 假设汉字词条在第二列，列名为"汉字词"
    $word = $row.'汉字词'
    if ($word -and $word.Length -eq 4) {  # 只提取恰好是4个汉字的词条
        $words += $word
    }
}

# 生成TypeScript文件内容
$tsContent = "// 四字词条\n\nexport const siziWords: string[] = [\n"

# 每十个元素一行
for ($i = 0; $i -lt $words.Count; $i++) {
    # 每行开始添加两个空格作为缩进
    if ($i % 10 -eq 0) {
        if ($i -gt 0) {
            $tsContent += "\n  "
        } else {
            $tsContent += "  "
        }
    }
    
    # 添加带引号的词条
    $tsContent += "'$($words[$i])'"
    
    # 如果不是最后一个元素，添加逗号和空格
    if ($i -lt $words.Count - 1) {
        # 如果是每行的最后一个元素（除了最后一行），只添加逗号
        if (($i + 1) % 10 -eq 0) {
            $tsContent += ","
        } else {
            $tsContent += ", "
        }
    }
}

# 完成数组并添加剩余内容
$tsContent += "\n]\n\nexport const siziSet = new Set(siziWords)\n\n// 判断是否为四字词条\nexport function isSizi(text: string): boolean {\n  return siziSet.has(text)\n}\n"

# 写入TypeScript文件
Write-Host "正在生成TypeScript文件: $tsPath"
$tsContent | Out-File -FilePath $tsPath -Encoding utf8

Write-Host "完成！共提取了 $($words.Count) 个四字词条。"