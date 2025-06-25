Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Text;

public static class NuclearOptimizer {
    public static void GenerateFromTemplate(string filename, DateTime baseDate) {
        const int COUNT = 50000;
        var rnd = new Random(12345);
        
        // Pre-compute ALL possible components
        var plcs = new string[] {"PLC_A", "PLC_B", "PLC_C", "PLC_D"};
        var errors = new string[] {"Sandextractor overload", "Conveyor misalignment", "Valve stuck", "Temperature warning"};
        var statuses = new string[] {"OK", "WARN", "ERR"};
        
        // Pre-generate all timestamps in one batch (MAJOR optimization)
        var timestamps = new string[COUNT];
        for (int i = 0; i < COUNT; i++) {
            timestamps[i] = baseDate.AddSeconds(-i).ToString("yyyy-MM-dd HH:mm:ss");
        }
        
        // Pre-generate random values in batches to reduce function call overhead
        var plcIndices = new int[COUNT];
        var opValues = new string[COUNT];
        var batchValues = new string[COUNT];
        var statusIndices = new int[COUNT];
        var tempValues = new string[COUNT];
        var loadValues = new string[COUNT];
        var errorFlags = new bool[COUNT];
        var errorIndices = new int[COUNT];
        var sandValues = new string[COUNT];
        
        for (int i = 0; i < COUNT; i++) {
            plcIndices[i] = rnd.Next(4);  // More efficient than bitwise AND
            opValues[i] = (101 + (rnd.Next(20))).ToString();
            batchValues[i] = (1000 + (rnd.Next(101))).ToString();
            statusIndices[i] = rnd.Next(3);
            tempValues[i] = (60 + rnd.Next(50) + rnd.NextDouble()).ToString("F2");
            loadValues[i] = rnd.Next(101).ToString();
            errorFlags[i] = (rnd.Next(8) == 4);  // 1/8 chance for errors
            errorIndices[i] = rnd.Next(4);
            sandValues[i] = (1 + rnd.Next(10)).ToString();
        }
        
        // Optimized StringBuilder with better initial capacity
        var sb = new StringBuilder(COUNT * 120);  // Slightly larger estimate
        
        // Main generation loop with minimal operations
        for (int i = 0; i < COUNT; i++) {
            var plc = plcs[plcIndices[i]];
            var status = statuses[statusIndices[i]];
            var timestamp = timestamps[i];
            var op = opValues[i];
            var batch = batchValues[i];
            var temp = tempValues[i];
            var load = loadValues[i];
            
            if (errorFlags[i]) {
                var errIdx = errorIndices[i];
                var err = errors[errIdx];
                
                if (errIdx == 0) {
                    sb.Append("ERROR; ").Append(timestamp).Append("; ").Append(plc).Append("; ").Append(err)
                      .Append("; ").Append(sandValues[i]).Append("; ").Append(status).Append("; ").Append(op)
                      .Append("; ").Append(batch).Append("; ").Append(temp).Append("; ").Append(load).AppendLine();
                } else {
                    sb.Append("ERROR; ").Append(timestamp).Append("; ").Append(plc).Append("; ").Append(err)
                      .Append("; ; ").Append(status).Append("; ").Append(op).Append("; ").Append(batch)
                      .Append("; ").Append(temp).Append("; ").Append(load).AppendLine();
                }
            } else {
                sb.Append("INFO; ").Append(timestamp).Append("; ").Append(plc)
                  .Append("; System running normally; ; ").Append(status).Append("; ").Append(op)
                  .Append("; ").Append(batch).Append("; ").Append(temp).Append("; ").Append(load).AppendLine();
            }
        }
        
        // Single atomic write
        File.WriteAllText(filename, sb.ToString(), Encoding.UTF8);
    }
}
"@
Measure-Command{
    [NuclearOptimizer]::GenerateFromTemplate("plc_log.txt", (Get-Date))
    Write-Output "PLC log file generated."
}