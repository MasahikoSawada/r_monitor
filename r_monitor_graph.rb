#!/usr/bin/env ruby

require 'csv'
require 'gnuplot'

time = []
c1 = []
c2 = []
c3 = []

def num2unit(num, unit = "kb")
  if unit.casecmp("kb")
    return num / 1024
  elsif unit.casecmp("mb")
    return num / 1024 / 1024
  elsif unit.casecmp("gb")
    return num / 1024 / 1024
  end
end

csv_data = CSV.read(ARGV[0], headers: true)
csv_data.each do |data|
  time << data["time"]
  c1 << num2unit(data["dt"].to_i)
  c2 << num2unit(data["wb"].to_i)
  c3 << num2unit(data["fr"].to_i)
end

p "dt"
p c1
p "wb"
p c2
p "fr"
p c3

Gnuplot.open do |gp|
  Gnuplot::Plot.new( gp ) do |plot|
    plot.title  'test'
    plot.ylabel 'ylabel'
    plot.xlabel 'xlabel'
    plot.xdata 'time'
    plot.timefmt '"%Y/%m/%d %H:%M:%S"'
    plot.format 'x "%H:%M:%S"'

    plot.data << Gnuplot::DataSet.new( [time, c1] ) do |ds|
      ds.with = "lines"
      ds.using = "1:3"
      ds.title = "dt"
    end

    plot.data << Gnuplot::DataSet.new( [time, c1, c2, c3] ) do |ds|
      ds.with = "lines"
      ds.using = "1:4"
      ds.title = "wb"
    end

    plot.data << Gnuplot::DataSet.new( [time, c1, c2, c3] ) do |ds|
      ds.with = "lines"
      ds.using = "1:5"
      ds.title = "fr"
    end

  end
end
