# r_monitor
Monitoring and Report Tools in Ruby.

# r_pgbench.rb
r_pgbench.rb generates the histgram graph and the scatter plot graph from log file is generated by `pgbench -l`.

## Options
|Option|Description|
|:----:|:---------:|
|-f logfile|Specify the path of log file generated by `pgbench -l`. Process data from stdin when `-` or not spcified|
|-o pngfile|Specify the path of output .ong file. Display in new window by default.|

## Usage
```
/* From file */
$ ruby r_pgbench.rb -f pgbench_log.12345 -o graph.png
/* From stdin */
$ cat pgbench_log.12345 | ruby r_pgbench.rb -o graph.png
```

## Sample
```
$ ruby r_pgbench.rb -f pgbench_log.12345 -o graph.png
================= Summary =================
Total transactions    : 16236 (xacts)
Duration              : 59.994291 (sec)
Response Time 90%tile : 18.961000 (msec)
              Min     : 3.413000 (msec)
              Max     : 132.800000 (msec)
Thoughput Average     : 270.625750 (TPS)
===========================================
```

![image](images/sample_pgbench.png)