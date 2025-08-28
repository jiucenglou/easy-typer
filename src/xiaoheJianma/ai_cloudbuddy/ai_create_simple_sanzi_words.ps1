# PowerShell script to create a simple sanziWords.ts file with one word per line
try {
    # 首先，从原始Excel文件中提取三字词条
    Write-Host "正在启动Excel应用程序..."
    $excel = New-Object -ComObject Excel.Application
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    # 打开Excel文件
    $sourceFilePath = "src\xiaoheJianma\微软五笔挂接小鹤音形码表-三字词条.xlsx"
    Write-Host "正在打开源工作簿: $sourceFilePath"
    
    $sourceWorkbook = $excel.Workbooks.Open((Resolve-Path $sourceFilePath).Path)
    $sourceWorksheet = $sourceWorkbook.Worksheets.Item(1)

    # 获取行数
    $rowCount = $sourceWorksheet.UsedRange.Rows.Count
    Write-Host "工作表有 $rowCount 行"

    # 提取词条
    Write-Host "正在提取汉字词..."
    $words = @()
    
    for ($row = 2; $row -le $rowCount; $row++) {
        $cellValue = $sourceWorksheet.Cells.Item($row, 2).Value2
        
        if ($null -ne $cellValue) {
            $words += "$cellValue"
        }
    }

    # 关闭Excel
    $sourceWorkbook.Close($false)
    $excel.Quit()
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null

    Write-Host "共提取到 $($words.Count) 个词条"

    # 创建新的TypeScript文件
    $tsFilePath = "src\xiaoheJianma\sanziWords.ts"
    Write-Host "正在创建TypeScript文件: $tsFilePath"
    
    # 构建文件内容 - 每个词条单独一行
    $tsContent = "export const sanziWords = [\n"
    
    for ($i = 0; $i -lt $words.Count; $i++) {
        # 添加词条，带单引号和逗号（最后一个元素不加逗号）
        if ($i -eq $words.Count - 1) {
            $tsContent += "  '$($words[$i])'"
        } else {
            $tsContent += "  '$($words[$i])',"
        }
        
        # 每个词条后面添加换行符
        $tsContent += "\n"
    }
    
    $tsContent += "];"
    
    # 写入文件
    [System.IO.File]::WriteAllText($tsFilePath, $tsContent, [System.Text.Encoding]::UTF8)
    
    # 验证文件内容
    $sample = $tsContent.Substring(0, [Math]::Min(200, $tsContent.Length))
    Write-Host "文件开头示例:"
    Write-Host $sample
    
    Write-Host "完成！已创建包含逗号分隔元素的文件。"
} catch {
    Write-Host "错误: $_"
    Write-Host "错误位置: $($_.ScriptStackTrace)"
}