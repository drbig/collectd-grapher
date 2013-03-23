# coding: utf-8
#

RRD_PATH = '/mnt/drbig/collectd'
GRAPH_PATH = Dir.pwd

CONTRAST = 6

RESOLUTIONS = %w{ 24h 7d 100d }

PLUGINS = {
  :cpu => {
    "all" => {
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
    "all" => {
      :y_axis_title => 'Bytes',
      :prefix => 'memory-',
      :order => %w{ active inactive cache wired free },
      :pallette => %w{ #AAFFAA #AAAAFF #FFAAAA #AAFFFF #FFAAFF },
      :chart => 'area',
      :stack => true,
      :max => true,
      :min => false,
    }
  },
  :df => {
    "all" => {
      :y_axis_title => 'Bytes',
      :prefix => 'df_complex-',
      :order => %w{ used },
      :pallette => ['#FFAAAA'],
      :chart => 'area',
      :stack => false,
      :max => true,
      :min => false,
    }
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
    }
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
    }
  }, 
  :df => {
    "all" => {
      :y_axis_title => 'Bytes',
      :prefix => 'df_complex-',
      :order => %w{ used },
      :pallette => %w{ #FFAAAA },
      :chart => 'area',
      :stack => false,
      :max => true,
      :min => false,
    }
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
      :max => true,
      :min => false
    },
    "fan" => {
      :y_axis_title => 'RPM',
      :prefix => 'fanspeed-',
      :order => %w{ 1 },
      :titles => ['CPU Fan'],
      :pallette => %w{ #FF6666 },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => false
    },
    "v-core" => {
      :y_axis_title => 'Volt',
      :prefix => 'voltage-',
      :order => %w{ C0 C1 },
      :titles => ['2.3 V', '3.5 V'],
      :pallette => %w{ #FF6666 #66FF66 },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => true
    },
    "v-atx" => {
      :y_axis_title => 'Volt',
      :prefix => 'voltage-',
      :order => %w{ 12P 50P 33 50N 12N },
      :titles => ['12 V', '5 V', '3.3 V', '-5 V', '-12 V'],
      :pallette => %w{ #FF6666 #66FF66 #6666FF #66FFF6 #FFF666 },
      :chart => 'line2',
      :stack => false,
      :max => true,
      :min => true
    }
  }
}
