# PowerShell script to extract multi-character entries from Excel file
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

    # Open the source workbook
    $sourceFilePath = "src\xiaoheJianma\微软五笔挂接小鹤音形码表.xlsx"
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
    $colCount = $usedRange.Columns.Count
    Write-Host "工作表有 $rowCount 行和 $colCount 列"

    # Create a new workbook for multi-character entries
    Write-Host "正在创建新工作簿..."
    $destWorkbook = $excel.Workbooks.Add()
    $destWorksheet = $destWorkbook.Worksheets.Item(1)
    $destWorksheet.Name = "多字词条"

    # Create headers
    Write-Host "正在创建表头..."
    $destWorksheet.Cells.Item(1, 1).Value2 = "编码"
    $destWorksheet.Cells.Item(1, 2).Value2 = "汉字词"

    # Process each row
    Write-Host "开始处理数据行..."
    $newRow = 2  # Start from row 2 (assuming row 1 is header)
    $extractedCount = 0
    
    for ($row = 2; $row -le $rowCount; $row++) {
        # 获取第2列的值（汉字词）
        $cellValue = $sourceWorksheet.Cells.Item($row, 2).Value2
        
        # 跳过空值
        if ($null -eq $cellValue) {
            continue
        }
        
        # 将值转换为字符串并检查中文字符数量
        $stringValue = "$cellValue"  # 使用字符串插值将任何类型转换为字符串
        
        # 计算中文字符数量
        $chineseChars = $stringValue -replace '[^\u4e00-\u9fff]', ''
        
        if ($chineseChars.Length -gt 1) {
            # 复制编码和汉字词到新工作表
            $destWorksheet.Cells.Item($newRow, 1).Value2 = $sourceWorksheet.Cells.Item($row, 1).Value2
            $destWorksheet.Cells.Item($newRow, 2).Value2 = $cellValue
            $newRow++
            $extractedCount++
            
            # 每处理1000行输出一次进度
            if ($extractedCount % 1000 -eq 0) {
                Write-Host "已提取 $extractedCount 个多字词条..."
            }
        }
    }

    # Save the destination workbook
    $destFilePath = "src\xiaoheJianma\多字词条.xlsx"
    Write-Host "正在保存目标工作簿到: $destFilePath"
    $destWorkbook.SaveAs((Resolve-Path ".").Path + "\$destFilePath")

    # Close workbooks
    Write-Host "正在关闭工作簿..."
    $sourceWorkbook.Close($false)  # Close without saving changes
    $destWorkbook.Close($true)  # Close and save changes
    $excel.Quit()

    # Release COM objects
    Write-Host "正在释放COM对象..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($destWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($destWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    Write-Host "提取完成。已将$extractedCount个多字词条保存到'$destFilePath'文件中。"
} catch {
    Write-Host "错误: $_"
    Write-Host "错误位置: $($_.ScriptStackTrace)"
    
    # Try to clean up if there was an error
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
}