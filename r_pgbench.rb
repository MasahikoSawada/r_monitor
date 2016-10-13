#!/usr/bin/env ruby
# coding: utf-8

require 'csv'
require 'gnuplot'
require 'optparse'

$logfile = ""
$output = ""

# Parse options
opt = OptionParser.new
params = {}
opt.on('-f pgbench log file') { |v| params[:f] = v }
opt.on('-o output file (.png)') { |v| params[:o] = v }
opt.parse!(ARGV)

$logfile = params[:f]
$output = params[:o]
input = ($logfile.nil? || $logfile == '-') ? STDIN : File.open($logfile)

i = 0
base_sec = 0
base_nano = 0
duration_max = 0
ar_time = []
ar_duration = []

# Read CSV data that is outputed by pgbench -l option while
# constructing data for the scatter plot
CSV.filter(input, open(File::NULL, ?w), col_sep: " ") do |data|
  # Get base second
  base_sec = data[4].to_i if i == 0
  base_nano = data[5].to_i if i == 0

  # Calcualte
  time = (data[4].to_f - base_sec) + (data[5].to_f - base_nano)/1000000
  duration = data[2].to_f / 1000

  # Store both into the array
  ar_time << time
  ar_duration << duration
  i += 1
end

# Calcurate 90% tile
ar_duration_sorted = ar_duration.sort
ninety_percent = (i * 0.9).to_i
ninety_percent_tile = (ar_duration_sorted[ninety_percent] + 1).to_i

# Construt data for histgram graph
hist_len = ar_duration.length + 1
hist_duration = Array.new(hist_len, 0)
hist_num = Array.new(hist_len, 0)
prev = 0
i = 0
ar_duration_sorted.each do | d |
  duration = d.round(1) # per 100ms

  hist_duration[i] = duration
  hist_num[i] += 1
  i += 1 if prev != duration && prev != 0
  prev = duration
end

# Plot Scatter plot and histgram of pgbench response time
Gnuplot.open do |gp|

  # Draw at the bottom
  Gnuplot::Plot.new(gp) do |plot|
    # Global setting
    plot.title 'Response-Time Scatter Plot'
    if !$output.nil?
      plot.terminal 'png size 1280, 720'
      plot.output "#{$output}"
    end
    plot.terminal 'x11 size 1280 720'

    # Enter multiplot mode
    plot.multiplot

    # Set label name
    plot.xlabel 'Time'
    plot.ylabel 'Response Time(msec)'

    # Enable grid
    plot.grid 'lw 2'

    # Specify graph size and location
    plot.size '1.0,0.4'
    plot.origin '0.0,0.0'
    plot.tmargin '0' # Remove top margin

    # Plot
    plot.data << Gnuplot::DataSet.new( [ar_time, ar_duration]) do |ds|
      ds.notitle
    end
  end

  # Draw at the top
  Gnuplot::Plot.new(gp) do |plot|
    #plot.multiplot
    plot.title 'Response-Time Histgram'
    plot.style 'fill solid 0.1 border'
    plot.xrange "[#{ar_duration_sorted[0].to_i}:#{ninety_percent_tile}]"
    plot.xtics '0.1'
    plot.format 'x "%4.1f"'

    # Set label name
    plot.xlabel 'Response Time(msec)'
    plot.ylabel 'Count'

    # Enable grid
    plot.grid 'lw 2'

    # Specify graph size and location
    plot.size '1.0,0.4'
    plot.origin '0.0,0.5'

    # Plot
    plot.data << Gnuplot::DataSet.new( [hist_duration, hist_num] ) do | ds |
      ds.with = "boxes"
      ds.title = "count"
      ds.linecolor = 'rgb "cyan"'
      ds.linewidth = 1
    end
  end
end

# Ouput Summary
puts "================= Summary ================="
puts "Total transactions    : %d (xacts)" % ar_duration.length
puts "Duration              : %f (sec)" % ar_time.max
puts "Response Time 90%%tile : %f (msec)" % ar_duration_sorted[ninety_percent]
puts "              Min     : %f (msec)" % ar_duration.min
puts "              Max     : %f (msec)" % ar_duration.max
puts "Thoughput Average     : %f (TPS)" % (ar_duration.length / ar_time.max)
puts "==========================================="
