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

#
#
def build_draw(plugin_path, label, index, config, aggregator)
  deflabel = label
  if config.has_key? :single_file
    label = ''
  end

  if aggregator != :average
    command = " LINE1:#{deflabel}_#{aggregator}\\"
    case aggregator
    when :max
      command += highlight(config[:pallette][index], -CONTRAST)
    when :min
      command += highlight(config[:pallette][index], CONTRAST)
    else
      command += config[:palette][index]
    end
  else
    command = " #{config[:chart].upcase}:#{deflabel}_#{aggregator}\\#{config[:pallette][index]}"
  end

  if config.has_key? :titles
    command += ":'#{config[:titles][index]}"
  else
    command += ":'#{label.capitalize}"
  end

  command += AGGREGATOR_LABELS[aggregator] if AGGREGATOR_LABELS.has_key? aggregator

  if index == config[:order].length - 1
    command += "\\n'"
  else
    command += "'"
  end
  command += ':STACK' if (config[:stack] and index > 0)

  command
end

#
#
def build_def(plugin_path, label, index, config, aggregator)
  deflabel = label
  if config.has_key? :single_file
    label = ''
  end

  if config.has_key? :ds_names
    command = " DEF:#{deflabel}_#{aggregator}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:#{config[:ds_names][index]}:#{aggregator.to_s.upcase}"
  else
    command = " DEF:#{deflabel}_#{aggregator}=#{plugin_path.join(config[:prefix] + label + '.rrd')}:value:#{aggregator.to_s.upcase}"
  end
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

        if config.has_key? :single_file # and (not config.has_key? :ds_names)
          config[:ds_names] = config[:order]
        end

        ## DEFS
        #######
        config[:order].each_with_index do |label, index|
          command += build_def(plugin_path, label, index, config, :average)
          command += build_def(plugin_path, label, index, config, :max) if config[:max]
          command += build_def(plugin_path, label, index, config, :min) if config[:min]
        end

        ## GRAPHING
        ###########
        if config[:min]
          config[:order].each_with_index do |label, index|
            command += build_draw(plugin_path, label, index, config, :min)
          end
        end

        config[:order].each_with_index do |label, index|
          command += build_draw(plugin_path, label, index, config, :average)
        end

        if config[:max]
          config[:order].each_with_index do |label, index|
            command += build_draw(plugin_path, label, index, config, :max)
          end
        end

        puts command
        Kernel.system(command)
      end
    end
  end
end

puts images.sort.join("\n")
