#!/usr/bin/env ruby

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

# Construt data for histgram graph
hist_range = ar_duration.max + 1
hist_num = Array.new(hist_range, 0)
ar_duration.each do | d |
  hist_num[d.to_i] += 1
end

# Plot Scatter plot and histgram of pgbench response time
Gnuplot.open do |gp|

  # Draw at the bottom
  Gnuplot::Plot.new(gp) do |plot|
    # Global setting
    plot.title 'Response-Time Scatter Plot'
    if !$output.nil?
      plot.terminal 'png'
      plot.output "#{$output}.png"
    end

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
    plot.xrange "[0:#{hist_range}]"
    
    # Set label name
    plot.xlabel 'Response Time(msec)'
    plot.ylabel 'Count'

    # Enable grid
    plot.grid 'lw 2'

    # Specify graph size and location
    plot.size '1.0,0.4'
    plot.origin '0.0,0.5'

    # Plot
    plot.data << Gnuplot::DataSet.new( hist_num ) do | ds |
      ds.with = "boxes"
      ds.title = "count"
      ds.linecolor = 'rgb "cyan"'
      ds.linewidth = 1
    end
  end
end
