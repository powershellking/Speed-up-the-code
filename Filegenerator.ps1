Measure-Command{
    $bigFileName = "plc_log.txt"
    $plcNames = 'PLC_A','PLC_B','PLC_C','PLC_D'
    $errorTypes = @(
        'Sandextrator overload',
        'Conveyor misalignment', 
        'Valve stuck',
        'Temperature warning'
    )
    $statusCodes = 'OK','WARN','ERR'
    
    # Determine optimal batch size based on CPU cores
    $batchSize = [Math]::Max(1000, 50000 / ([Environment]::ProcessorCount * 2))
    $totalRecords = 50000
    $baseDate = Get-Date
    
    # Create batches for parallel processing
    $batches = 0..([Math]::Ceiling($totalRecords / $batchSize) - 1) | ForEach-Object {
        $startIndex = $_ * $batchSize
        $endIndex = [Math]::Min($startIndex + $batchSize - 1, $totalRecords - 1)
        @{
            StartIndex = $startIndex
            EndIndex = $endIndex
            Count = $endIndex - $startIndex + 1
        }
    }
    
    # Process batches in parallel
    $logLines = $batches | ForEach-Object -Parallel {
        # Import variables into parallel scope
        $plcNames = $using:plcNames
        $errorTypes = $using:errorTypes
        $statusCodes = $using:statusCodes
        $baseDate = $using:baseDate
        $batch = $_
        
        # Create thread-local random generator with unique seed
        $rnd = [System.Random]::new([System.Threading.Thread]::CurrentThread.ManagedThreadId + [System.DateTime]::Now.Millisecond)
        
        # Pre-allocate array for this batch
        $batchLines = [System.Collections.ArrayList]::new($batch.Count)
        
        for ($i = $batch.StartIndex; $i -le $batch.EndIndex; $i++) {
            # More efficient timestamp calculation
            $timestamp = $baseDate.AddSeconds(-$i).ToString("yyyy-MM-dd HH:mm:ss")
            
            # Direct array indexing with thread-local random
            $plc = $plcNames[$rnd.Next(0, 4)]
            $operator = $rnd.Next(101, 121)
            $batchNum = $rnd.Next(1000, 1101)
            $status = $statusCodes[$rnd.Next(0, 3)]
            $machineTemp = [math]::Round($rnd.Next(60, 110) + $rnd.NextDouble(), 2)
            $load = $rnd.Next(0, 101)
            
            if ($rnd.Next(1, 8) -eq 4) {
                $errorType = $errorTypes[$rnd.Next(0, 4)]
                if ($errorType -eq 'Sandextrator overload') {
                    $value = $rnd.Next(1, 11)
                    $msg = "ERROR; $timestamp; $plc; $errorType; $value; $status; $operator; $batchNum; $machineTemp; $load"
                } else {
                    $msg = "ERROR; $timestamp; $plc; $errorType; ; $status; $operator; $batchNum; $machineTemp; $load"
                }
            } else {
                $msg = "INFO; $timestamp; $plc; System running normally; ; $status; $operator; $batchNum; $machineTemp; $load"
            }
            
            [void]$batchLines.Add($msg)
        }
        
        # Return the batch results
        return $batchLines.ToArray()
    } -ThrottleLimit ([Environment]::ProcessorCount)
    
    # Flatten the results and write to file
    $allLines = $logLines | ForEach-Object { $_ }
    Set-Content -Path $bigFileName -Value $allLines
    Write-Output "PLC log file generated with $($allLines.Count) records using $([Environment]::ProcessorCount) CPU cores."
}