# PowerShell script to convert Excel words to TypeScript array
try {
    Write-Host "正在启动Excel应用程序..."
    # Load the Excel COM object
    $excel = New-Object -ComObject Excel.Application
    if ($null -eq $excel) {
        Write-Host "错误: 无法创建Excel COM对象"
        exit 1
    }
    
    $excel.Visible = $false
    $excel.DisplayAlerts = $false

    # Open the source workbook - 使用正确的文件名
    $sourceFilePath = "src\xiaoheJianma\微软五笔挂接小鹤音形码表-三字词条.xlsx"
    Write-Host "正在打开源工作簿: $sourceFilePath"
    
    if (-not (Test-Path $sourceFilePath)) {
        Write-Host "错误: 文件不存在: $sourceFilePath"
        exit 1
    }
    
    $sourceWorkbook = $excel.Workbooks.Open((Resolve-Path $sourceFilePath).Path)
    if ($null -eq $sourceWorkbook) {
        Write-Host "错误: 无法打开源工作簿"
        exit 1
    }
    
    Write-Host "源工作簿已打开，正在访问工作表..."
    $sourceWorksheet = $sourceWorkbook.Worksheets.Item(1)
    if ($null -eq $sourceWorksheet) {
        Write-Host "错误: 无法访问第一个工作表"
        exit 1
    }

    # Get the used range
    Write-Host "正在获取已使用的单元格范围..."
    $usedRange = $sourceWorksheet.UsedRange
    $rowCount = $usedRange.Rows.Count
    Write-Host "工作表有 $rowCount 行"

    # Extract words from the second column (汉字词)
    Write-Host "正在提取汉字词..."
    $words = @()
    
    for ($row = 2; $row -le $rowCount; $row++) {
        $cellValue = $sourceWorksheet.Cells.Item($row, 2).Value2
        
        if ($null -ne $cellValue) {
            $words += "$cellValue"
        }
        
        # 每处理1000行输出一次进度
        if (($row - 1) % 1000 -eq 0) {
            Write-Host "已处理 $($row - 1) 行..."
        }
    }

    # Close Excel
    Write-Host "正在关闭Excel..."
    $sourceWorkbook.Close($false)  # Close without saving changes
    $excel.Quit()

    # Release COM objects
    Write-Host "正在释放COM对象..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    # Create TypeScript file with proper formatting
    Write-Host "正在创建TypeScript文件..."
    $tsFilePath = "src\xiaoheJianma\sanziWords.ts"
    
    # 直接构建完整的字符串，确保元素之间有逗号
    $tsContent = "export const sanziWords = [`n"
    
    for ($i = 0; $i -lt $words.Count; $i++) {
        # 每10个词一行
        if ($i % 10 -eq 0) {
            if ($i -gt 0) {
                $tsContent += "`n  "
            } else {
                $tsContent += "  "
            }
        }
        
        # 添加词条，带单引号和逗号
        $tsContent += "'$($words[$i])'"
        
        # 如果不是最后一个元素，添加逗号
        if ($i -lt $words.Count - 1) {
            $tsContent += ", "
        }
    }
    
    $tsContent += "`n];"
    
    # Write to file with UTF-8 encoding
    [System.IO.File]::WriteAllText($tsFilePath, $tsContent, [System.Text.Encoding]::UTF8)
    
    Write-Host "转换完成。已将 $($words.Count) 个三字词条保存到 $tsFilePath"
} catch {
    Write-Host "错误: $_"
    Write-Host "错误位置: $($_.ScriptStackTrace)"
    
    # Try to clean up if there was an error
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
}