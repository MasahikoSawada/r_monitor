#!/bin/env ruby

require "open3"

module ResultType
  TYPE_RAW = 1
  TYPE_UNIT = 2
end
include ResultType

########################
#
# Command list
# $1 : name.
# $2 : command which should return one line.
# $3 : flag.
#
########################
$cmd_list = [
            ["dt", "cat /proc/meminfo | grep Dirty: | cut -d \":\" -f 2", TYPE_UNIT],
            ["wb", "cat /proc/meminfo | grep Writeback: | cut -d \":\" -f 2", TYPE_UNIT],
            ["fr", "cat /proc/meminfo | grep MemFree: | cut -d \":\" -f 2", TYPE_UNIT]
           ]

# Append string r to given s.
def appendStr(s, r, escape = false)

  if escape
    r = "\"" + r + "\""
  end

  if s.empty?
    s << r
  else
    s << "," + r
  end

  return s
end

# Convert number with unit like 'kb', 'mb' to
# the number.
def unit2raw(str)
  val, unit = str.split()

  if unit.casecmp("kb")
    ret = val.to_i * 1024
  elsif unit.casecmp("mb")
    ret = val.to_i * 1024 * 1024
  elsif unit.casecmp("gb")
    ret = val.to_i * 1024 * 1024 * 1024
  end
     
  return ret.to_s
end

def getHeader()
  header = ""

  appendStr(header, "time")
  $cmd_list.each do | name, cmd, type |
    appendStr(header, name)
  end
  return header
end


# Main Logic

# Put header data
puts getHeader()

while true
  str = ""
  time = Time.now()

  appendStr(str, time.strftime("%Y/%m/%d %H:%M:%S"), true)

  # Collect information while iterating over command list.
  $cmd_list.each do | name, cmd, type |
    o, e, s = Open3.capture3(cmd) # Get info

    # Convert plain number if needed.
    if type == TYPE_UNIT
      o = unit2raw(o.strip)
    end

    # Append info to output string
    str = appendStr(str, o)
  end
  
  puts str
  sleep 1
end
