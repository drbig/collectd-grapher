#!/usr/bin/env ruby
# coding: utf-8
#

RRD_PATH = '/var/lib/collectd/rrd'
GRAPH_PATH = '/home/drbig/www/status/graphs'

CONTRAST = 6
AGGREGATOR_LABELS = { :average => ' avg', :max => ' max', :min => ' min' }
RESOLUTIONS = %w{ 24h 7d 100d }

PLUGINS = {
  :cpu => {
    "all" => {
      :y_axis_title => 'Jiffies',
      :prefix => 'cpu-',
      :order => %w{ idle user system interrupt nice softirq wait steal },
      :pallette => %w{ #AAFFAA #AAAAFF #FFAAAA #AAFFFF #FFAAFF #AFFAAA #AAAFFA #FAAAAF },
      :chart => 'area',
      :stack => false,
      :max => true,
    },
  },
  :memory => {
    "all" => {
      :y_axis_title => 'Bytes',
      :prefix => 'memory-',
      :order => %w{ used cached buffered free },
      :pallette => %w{ #AAFFAA #AAAAFF #FFAAAA #FFAAFF },
      :chart => 'area',
      :stack => true,
      :max => true,
      :min => false,
      :options => '-l 0',
    },
  },
  :interface => {
    "octets" => {
      :y_axis_title => 'Octetes/s',
      :prefix => 'if_octets',
      :single_file => true,
      :order => %w{ rx tx },
      :titles => %w{ Received Sent },
      :pallette => %w{ #FFAAAA #AAFFAA },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => false,
    },
  }, 
  :disk => {
    "octets" => {
      :y_axis_title => 'Octetes/s',
      :prefix => 'disk_octets',
      :single_file => true,
      :order => %w{ read write },
      :titles => %w{ Read Write },
      :pallette => %w{ #FFAAAA #AAFFAA },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => false,
    },
  }, 
  :df => {
    "all" => {
      :y_axis_title => 'Bytes',
      :prefix => 'df_complex-',
      :order => %w{ used free },
      :pallette => %w{ #FFAAAA #AAFFAA },
      :chart => 'area',
      :stack => true,
      :max => true,
      :min => false,
      :options => '-l 0',
    },
  },
  :load => {
    "all" => {
      :y_axis_title => 'Load',
      :prefix => 'load',
      :single_file => true,
      :order => %w{ shortterm longterm },
      :titles => ['Load short', 'Load long'],
      :pallette => %w{ #FFAAAA #AAFFAA },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => false,
    },
  },
}

if __FILE__ == $0
  def die(msg)
    STDERR.puts msg
    exit(2)
  end

  def has_all(info, container, keys)
    keys.each do |k|
      die("#{info} doesn't have #{k}") unless container.member? k
    end
  end

  die('RRD_PATH not a directory') unless (File.exists? RRD_PATH and File.directory? RRD_PATH)
  die('GRAPH_PATH not a directory') unless (File.exists? GRAPH_PATH and File.directory? GRAPH_PATH)
  die('CONTRAST has to be 0 <= x <= 16') unless (CONTRAST >= 0 and CONTRAST <= 16)
  has_all('AGGREGATOR LABELS', AGGREGATOR_LABELS, [:min, :max, :average])
  die('RESOLUTIONS has to have at least defined') if RESOLUTIONS.empty?

  PLUGINS.each_pair do |k, c|
    die("PLUGIN #{k} has no charts defined") if c.empty?
    c.each_pair do |n, c|
      where = "PLUGIN #{k} CHART #{n}"
      has_all(where, c, [:y_axis_title, :prefix, :chart, :order, :pallette])
      die("#{where} order.length != pallette.length") unless c[:order].length == c[:pallette].length
      if c.has_key? :titles
        die("#{where} order.length != titles.length") unless c[:order].length == c[:titles].length
      end
      if c.has_key? :ds_names
        die("#{where} order.length != ds_names.length") unless c[:order].length == c[:ds_names].length
      end
    end
  end

  puts 'Looks okay overall.'
  exit(0)
end
