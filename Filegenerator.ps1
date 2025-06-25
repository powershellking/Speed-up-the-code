Add-Type -TypeDefinition @"
using System;
using System.IO;
using System.Text;

public static class NuclearOptimizer {
    public static void GenerateFromTemplate(string filename, DateTime baseDate) {
        const int COUNT = 50000;
        var rnd = new Random(12345);
        
        // Keep the simple arrays
        var plcs = new string[] {"PLC_A", "PLC_B", "PLC_C", "PLC_D"};
        var errors = new string[] {"Sandextractor overload", "Conveyor misalignment", "Valve stuck", "Temperature warning"};
        var statuses = new string[] {"OK", "WARN", "ERR"};
        
        // Pre-generate only the expensive operations
        var timestamps = new string[COUNT];
        var temps = new string[COUNT];
        
        // Batch generate timestamps and temperature strings (these are the expensive ToString() calls)
        for (int i = 0; i < COUNT; i++) {
            timestamps[i] = baseDate.AddSeconds(-i).ToString("yyyy-MM-dd HH:mm:ss");
            temps[i] = (60 + rnd.Next(50) + rnd.NextDouble()).ToString("F2");
        }
        
        // Precise StringBuilder capacity
        var sb = new StringBuilder(COUNT * 90);
        
        // Keep the main loop simple and fast
        for (int i = 0; i < COUNT; i++) {
            var plc = plcs[rnd.Next(4)];
            var op = (101 + rnd.Next(20)).ToString();
            var batch = (1000 + rnd.Next(101)).ToString();
            var status = statuses[rnd.Next(3)];
            var load = rnd.Next(101).ToString();
            
            if (rnd.Next(8) == 4) {
                var errIdx = rnd.Next(4);
                var err = errors[errIdx];
                
                if (errIdx == 0) {
                    var val = (1 + rnd.Next(10)).ToString();
                    sb.Append("ERROR; ").Append(timestamps[i]).Append("; ").Append(plc).Append("; ").Append(err)
                      .Append("; ").Append(val).Append("; ").Append(status).Append("; ").Append(op)
                      .Append("; ").Append(batch).Append("; ").Append(temps[i]).Append("; ").Append(load).AppendLine();
                } else {
                    sb.Append("ERROR; ").Append(timestamps[i]).Append("; ").Append(plc).Append("; ").Append(err)
                      .Append("; ; ").Append(status).Append("; ").Append(op).Append("; ").Append(batch)
                      .Append("; ").Append(temps[i]).Append("; ").Append(load).AppendLine();
                }
            } else {
                sb.Append("INFO; ").Append(timestamps[i]).Append("; ").Append(plc)
                  .Append("; System running normally; ; ").Append(status).Append("; ").Append(op)
                  .Append("; ").Append(batch).Append("; ").Append(temps[i]).Append("; ").Append(load).AppendLine();
            }
        }
        
        // Simple write
        File.WriteAllText(filename, sb.ToString(), Encoding.UTF8);
    }
}
"@

Measure-Command{
    [NuclearOptimizer]::GenerateFromTemplate("plc_log.txt", (Get-Date))
    Write-Output "PLC log file generated."
}
