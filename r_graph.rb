#!/usr/bin/env ruby

require 'csv'
require 'gnuplot'

time = []
c1 = []
c2 = []
c3 = []

csv_data = CSV.read(ARGV[0], headers: true)
csv_data.each do |data|
  time << data["time"]
  c1 << data["dt"].to_i
  c2 << data["wb"].to_i
  c3 << data["fr"].to_i
end

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
    end

    plot.data << Gnuplot::DataSet.new( [time, c1, c2, c3] ) do |ds|
      ds.with = "lines"
      ds.using = "1:4"
    end

    plot.data << Gnuplot::DataSet.new( [time, c1, c2, c3] ) do |ds|
      ds.with = "lines"
      ds.using = "1:5"
    end

  end
end
