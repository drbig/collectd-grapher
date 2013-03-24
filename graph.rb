#!/usr/bin/env ruby
# coding: utf-8
#

require 'pathname'
require_relative 'config.rb'

#
#
def highlight(html_color, amount)
  html_color.each_char.to_a.collect do |c|
    if c =~ /[0-9A-F]/ and c != 'F'
      n = c.to_i(16) + amount
      (if n < 0
        0
      elsif n > 16
        16
      else
        n
      end).to_s(16)
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
        command += (' ' + config[:options]) if config.has_key? :options

        if (config.has_key? :single_file) # and (not config.has_key? :ds_names)
          config[:ds_names] = config[:order]
        end

        ## DEFS
        #######
        config[:order].each_with_index do |label, index|
          deflabel = label
          if config.has_key? :single_file
            label = ''
          end

          if config.has_key? :ds_names
            command += " DEF:#{deflabel}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:AVERAGE"
          else
            command += " DEF:#{deflabel}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:AVERAGE"
          end
        end

        if config[:max]
          config[:order].each_with_index do |label, index|
            deflabel = label
            if config.has_key? :single_file
              label = ''
            end

            if config.has_key? :ds_names
              command += " DEF:#{deflabel}_max=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:MAX"
            else
              command += " DEF:#{deflabel}_max=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:MAX"
            end
          end
        end

        if config[:min]
          config[:order].each_with_index do |label, index|
            deflabel = label
            if config.has_key? :single_file
              label = ''
            end

            if config.has_key? :ds_names
              command += " DEF:#{deflabel}_min=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:MIN"
            else
              command += " DEF:#{deflabel}_min=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:MIN"
            end
          end
        end

        ## GRAPHING
        ###########
        if config[:min]
          config[:order].each_with_index do |label, index|
            deflabel = label
            if config.has_key? :single_file
              label = ''
            end

            if config.has_key? :titles
              command += " LINE1:#{deflabel}_min\\#{highlight(config[:pallette][index], CONTRAST)}:'#{config[:titles][index]} min"
            else
              command += " LINE1:#{deflabel}_min\\#{highlight(config[:pallette][index], CONTRAST)}:'#{label.capitalize} min"
            end
            if index == config[:order].length - 1
              command += "\\n'"
            else
              command += "'"
            end
            command += ':STACK' if (config[:stack] and index > 0)
          end
        end

        config[:order].each_with_index do |label, index|
          deflabel = label
          if config.has_key? :single_file
            label = ''
          end

          if config.has_key? :titles
            command += " #{config[:chart].upcase}:#{deflabel}\\#{config[:pallette][index]}:'#{config[:titles][index]} avg"
          else
            command += " #{config[:chart].upcase}:#{deflabel}\\#{config[:pallette][index]}:'#{label.capitalize} avg"
          end
          if index == config[:order].length - 1
            command += "\\n'"
          else
            command += "'"
          end
          command += ':STACK' if (config[:stack] and index > 0)
        end

        if config[:max]
          config[:order].each_with_index do |label, index|
            deflabel = label
            if config.has_key? :single_file
              label = ''
            end

            if config.has_key? :titles
              command += " LINE1:#{deflabel}_max\\#{highlight(config[:pallette][index], -CONTRAST)}:'#{config[:titles][index]} max"
            else
              command += " LINE1:#{deflabel}_max\\#{highlight(config[:pallette][index], -CONTRAST)}:'#{label.capitalize} max"
            end
            if index == config[:order].length - 1
              command += "\\n'"
            else
              command += "'"
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

puts images.sort.join("\n")
