# PowerShell script to split multi-character entries by character count
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
    $sourceFilePath = "src\xiaoheJianma\多字词条.xlsx"
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

    # Create new workbooks for different character counts
    Write-Host "正在创建新工作簿..."
    $twoCharWorkbook = $excel.Workbooks.Add()
    $twoCharWorksheet = $twoCharWorkbook.Worksheets.Item(1)
    $twoCharWorksheet.Name = "二字词条"
    
    $threeCharWorkbook = $excel.Workbooks.Add()
    $threeCharWorksheet = $threeCharWorkbook.Worksheets.Item(1)
    $threeCharWorksheet.Name = "三字词条"
    
    $fourPlusCharWorkbook = $excel.Workbooks.Add()
    $fourPlusCharWorksheet = $fourPlusCharWorkbook.Worksheets.Item(1)
    $fourPlusCharWorksheet.Name = "四字及以上词条"

    # Create headers for all worksheets
    Write-Host "正在创建表头..."
    foreach ($worksheet in @($twoCharWorksheet, $threeCharWorksheet, $fourPlusCharWorksheet)) {
        $worksheet.Cells.Item(1, 1).Value2 = "编码"
        $worksheet.Cells.Item(1, 2).Value2 = "汉字词"
    }

    # Initialize row counters
    $twoCharRow = 2
    $threeCharRow = 2
    $fourPlusCharRow = 2
    
    # Initialize counters
    $twoCharCount = 0
    $threeCharCount = 0
    $fourPlusCharCount = 0

    # Process each row
    Write-Host "开始处理数据行..."
    for ($row = 2; $row -le $rowCount; $row++) {
        # 获取第2列的值（汉字词）
        $cellValue = $sourceWorksheet.Cells.Item($row, 2).Value2
        
        # 跳过空值
        if ($null -eq $cellValue) {
            continue
        }
        
        # 将值转换为字符串
        $stringValue = "$cellValue"
        
        # 计算中文字符数量
        $chineseChars = $stringValue -replace '[^\u4e00-\u9fff]', ''
        $charCount = $chineseChars.Length
        
        # 根据字符数量分配到不同的工作表
        if ($charCount -eq 2) {
            $twoCharWorksheet.Cells.Item($twoCharRow, 1).Value2 = $sourceWorksheet.Cells.Item($row, 1).Value2
            $twoCharWorksheet.Cells.Item($twoCharRow, 2).Value2 = $cellValue
            $twoCharRow++
            $twoCharCount++
            
            # 每处理1000行输出一次进度
            if ($twoCharCount % 1000 -eq 0) {
                Write-Host "已提取 $twoCharCount 个二字词条..."
            }
        }
        elseif ($charCount -eq 3) {
            $threeCharWorksheet.Cells.Item($threeCharRow, 1).Value2 = $sourceWorksheet.Cells.Item($row, 1).Value2
            $threeCharWorksheet.Cells.Item($threeCharRow, 2).Value2 = $cellValue
            $threeCharRow++
            $threeCharCount++
            
            # 每处理1000行输出一次进度
            if ($threeCharCount % 1000 -eq 0) {
                Write-Host "已提取 $threeCharCount 个三字词条..."
            }
        }
        elseif ($charCount -ge 4) {
            $fourPlusCharWorksheet.Cells.Item($fourPlusCharRow, 1).Value2 = $sourceWorksheet.Cells.Item($row, 1).Value2
            $fourPlusCharWorksheet.Cells.Item($fourPlusCharRow, 2).Value2 = $cellValue
            $fourPlusCharRow++
            $fourPlusCharCount++
            
            # 每处理1000行输出一次进度
            if ($fourPlusCharCount % 1000 -eq 0) {
                Write-Host "已提取 $fourPlusCharCount 个四字及以上词条..."
            }
        }
    }

    # Save the workbooks
    $basePath = (Resolve-Path ".").Path + "\src\xiaoheJianma\"
    Write-Host "正在保存工作簿..."
    
    $twoCharFilePath = "src\xiaoheJianma\二字词条.xlsx"
    $twoCharWorkbook.SaveAs($basePath + "二字词条.xlsx")
    
    $threeCharFilePath = "src\xiaoheJianma\三字词条.xlsx"
    $threeCharWorkbook.SaveAs($basePath + "三字词条.xlsx")
    
    $fourPlusCharFilePath = "src\xiaoheJianma\四字词条.xlsx"
    $fourPlusCharWorkbook.SaveAs($basePath + "四字词条.xlsx")

    # Close workbooks
    Write-Host "正在关闭工作簿..."
    $sourceWorkbook.Close($false)  # Close without saving changes
    $twoCharWorkbook.Close($true)  # Close and save changes
    $threeCharWorkbook.Close($true)  # Close and save changes
    $fourPlusCharWorkbook.Close($true)  # Close and save changes
    $excel.Quit()

    # Release COM objects
    Write-Host "正在释放COM对象..."
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($twoCharWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($threeCharWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($fourPlusCharWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorksheet) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($twoCharWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($threeCharWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($fourPlusCharWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($sourceWorkbook) | Out-Null
    [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    [System.GC]::Collect()
    [System.GC]::WaitForPendingFinalizers()

    Write-Host "分类完成。"
    Write-Host "二字词条: $twoCharCount 个，已保存到'$twoCharFilePath'"
    Write-Host "三字词条: $threeCharCount 个，已保存到'$threeCharFilePath'"
    Write-Host "四字及以上词条: $fourPlusCharCount 个，已保存到'$fourPlusCharFilePath'"
} catch {
    Write-Host "错误: $_"
    Write-Host "错误位置: $($_.ScriptStackTrace)"
    
    # Try to clean up if there was an error
    if ($excel) {
        $excel.Quit()
        [System.Runtime.Interopservices.Marshal]::ReleaseComObject($excel) | Out-Null
    }
}