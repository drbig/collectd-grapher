#!/usr/bin/env ruby
# coding: utf-8
#

require 'pathname'
require_relative 'config.rb'

#
#
def highlight(html_color)
  html_color.each_char.to_a.collect do |c|
    if c =~ /[0-9A-F]/ and c != 'F'
      n = c.to_i(16) - CONTRAST
      (n < 0 ? 0 : n).to_s(16)
    else
      c
    end
  end.join
end

images = Array.new

Pathname.new(RRD_PATH).each_child do |host_path|
  next if host_path.file?
  host_name = host_path.basename
  puts host_name

  host_path.each_child do |plugin_path|
    next if plugin_path.file?
    plugin_name = plugin_path.basename.to_s.split('-').first.to_sym
    next unless PLUGINS.member? plugin_name

    puts plugin_path

    RESOLUTIONS.each do |res|
      PLUGINS[plugin_name].each_pair do |name, config|

        graph_path = File.join(GRAPH_PATH, "#{host_name}-#{plugin_path.basename}-#{name}-#{res}.png")
        images << graph_path
        
        command = "rrdtool graph #{graph_path}"
        command += " --start end-#{res}"
        command += " -t '#{plugin_path.basename}/#{name} @ #{host_path.basename} - #{res}'"
        command += " -v '#{config[:y_axis_title]}'"

        config[:order].each_with_index do |label, index|
          if config.has_key? :ds_names
            command += " DEF:#{label}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:AVERAGE"
          else
            command += " DEF:#{label}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:AVERAGE"
          end
        end
        if config[:max]
          config[:order].each_with_index do |label, index|
            if config.has_key? :ds_names
              command += " DEF:#{label}_max=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:MAX"
            else
              command += " DEF:#{label}_max=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:MAX"
            end
          end
        end

        config[:order].each_with_index do |label, index|
          if config.has_key? :titles
            command += " #{config[:chart].upcase}:#{label}\\#{config[:pallette][index]}:'#{config[:titles][index]}'"
          else
            command += " #{config[:chart].upcase}:#{label}\\#{config[:pallette][index]}:'#{label.capitalize}'"
          end
          command += ':STACK' if (config[:stack] and index > 0)
        end
        if config[:max]
          config[:order].each_with_index do |label, index|
            if config.has_key? :titles
              command += " LINE1:#{label}_max\\#{highlight(config[:pallette][index])}:'#{config[:titles][index]} max'"
            else
              command += " LINE1:#{label}_max\\#{highlight(config[:pallette][index])}:'#{label.capitalize} max'"
            end
            command += ':STACK' if (config[:stack] and index > 0)
          end
        end

        puts command
        Kernel.system(command)
      end
    end
  end
end

puts images.join("\n")
