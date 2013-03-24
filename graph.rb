#!/usr/bin/env ruby
# coding: utf-8
#

require 'optparse'

def die(msg)
  STDERR.puts msg
  exit(2)
end

opts = { :debug => false, :paths => false }
oparser = OptionParser.new do |o|
  o.banner = "Usage: #{$0} [-d] [-p] config.rb"
  o.on('-d', '--debug', 'Print debugging statements') { opts[:debug] = true }
  o.on('-p', '--paths', 'Print paths of generated charts') { opts[:paths] = true }
end
oparser.parse! or die(oparser)
ARGV.length == 1 or die(oparser)

require_relative ARGV.shift
require 'pathname'

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
exit_status = 0

Pathname.new(RRD_PATH).each_child do |host_path|
  next if host_path.file?
  host_name = host_path.basename
  puts host_name if opts[:debug]

  host_path.each_child do |plugin_path|
    next if plugin_path.file?
    plugin_name = plugin_path.basename.to_s.split('-').first.to_sym
    next unless PLUGINS.member? plugin_name

    puts plugin_path if opts[:debug]

    RESOLUTIONS.each do |res|
      PLUGINS[plugin_name].each_pair do |name, config|

        graph_path = File.join(GRAPH_PATH, "#{host_name}-#{plugin_path.basename}-#{name}-#{res}.png")

        command = "rrdtool graph #{graph_path}"
        command += " --start end-#{res}"
        command += " -t '#{plugin_path.basename}/#{name} @ #{host_path.basename} - #{res}'"
        command += " -v '#{config[:y_axis_title]}'"
        command += (' ' + config[:options]) if config.has_key? :options

        if config.has_key? :single_file # and (not config.has_key? :ds_names)
          config[:ds_names] = config[:order]
        end

        ## DEFS
        # Order doesn't matter, so one loop will do.
        #######
        config[:order].each_with_index do |label, index|
          command += build_def(plugin_path, label, index, config, :average)
          command += build_def(plugin_path, label, index, config, :max) if config[:max]
          command += build_def(plugin_path, label, index, config, :min) if config[:min]
        end

        ## GRAPHING
        # Order does matter, so we have to have more loops.
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

        ## EXEC
        #######
        command += ' 2>&1'
        puts command if opts[:debug]
        output = IO.popen(command) {|io| io.read}
        if $?.success?
          images << graph_path
        else
          exit_status = 2
          STDERR.puts "Error at #{graph_path}"
          STDERR.puts output
        end

      end
    end
  end
end

puts images.sort.join("\n") if opts[:paths]
exit(exit_status)
