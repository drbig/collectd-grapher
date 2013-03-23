# coding: utf-8
#

RRD_PATH = '/mnt/drbig/collectd'
GRAPH_PATH = Dir.pwd

CONTRAST = 6

RESOLUTIONS = %w{ 24h 7d 100d }

PLUGINS = {
  :cpu => {
    "cpu" => {
      :y_axis_title => 'Jiffies',
      :prefix => 'cpu-',
      :order => %w{ idle user system interrupt nice },
      :pallette => %w{ #AAFFAA #AAAAFF #FFAAAA #AAFFFF #FFAAFF },
      :chart => 'area',
      :stack => false,
      :max => true
    }
  },
  :memory => {
    "mem" => {
      :y_axis_title => 'Bytes',
      :prefix => 'memory-',
      :order => %w{ active inactive cache wired free },
      :pallette => %w{ #AAFFAA #AAAAFF #FFAAAA #AAFFFF #FFAAFF },
      :chart => 'area',
      :stack => true,
      :max => true
    }
  },
  :mbmon => {
    "temps" => {
      :y_axis_title => '°C',
      :prefix => 'temperature-',
      :order => %w{ 0 1 },
      :titles => ['Core 0', 'Core 1'],
      :pallette => %w{ #FF6666 #66FF66 },
      :chart => 'line2',
      :stack => false,
      :max => true
    },
    "fan" => {
      :y_axis_title => 'RPM',
      :prefix => 'fanspeed-',
      :order => %w{ 1 },
      :titles => ['CPU Fan'],
      :pallette => %w{ #FF6666 },
      :chart => 'line2',
      :stack => false,
      :max => true
    },
    "voltages-core" => {
      :y_axis_title => 'Volt',
      :prefix => 'voltage-',
      :order => %w{ C0 C1 },
      :titles => ['2.3 V', '3.5 V'],
      :pallette => %w{ #FF6666 #66FF66 },
      :chart => 'line2',
      :stack => false,
      :max => true
    }

  }
}
