# collectd-grapher

[Collectd](https://collectd.org/) is really neat, and the choice of plugins! Of course what use is all that cool collected data if you can't really _see_ it. The script in here is yet another attempt at the problem of graphing [RRDtool](http://oss.oetiker.ch/rrdtool/) stuff.

Main assumptions for the script are:

- Be self-contained and data driven (*result*: you just need Ruby and RRDtool installed)
- Least amount of code, human-readable conifg (*result*: ugly code, but look at the configs)
- Strike a balance between what works out of the box and what you can customize (*result*: works for me)

*STATUS:* Current state is: "works for me, better ship earlier than 'complete'"

If I get any feedback I am willing to spend time making this better (obvious, ain't it?).

Look at example graphs, then read the configs.

## Example output

This is real, working output from my home server (config-freebsd-server.rb).

![Example 1 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-cpu-0-all-24h.png)
![Example 2 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-df-home-all-7d.png)
![Example 3 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-disk-ada0-octets-24h.png)
![Example 4 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-interface-tun0-octets-24h.png)
![Example 5 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-load-all-24h.png)
![Example 6 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-mbmon-fan-24h.png)
![Example 7 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-mbmon-temps-24h.png)
![Example 8 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-mbmon-v-atx-24h.png)
![Example 9 ](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-mbmon-v-core-24h.png)
![Example 10](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-memory-all-24h.png)
![Example 11](https://raw.github.com/drbig/collectd-grapher/master/graphs/kaer.eu.org-swap-all-24h.png)

## Usage

1. Edit and then run the config - it does basic sanity checks:

```
drbig@swordfish:pts/11 ~/P/collectd-grapher> ./config-linux-laptop.rb 
Looks okay overall.
```

2. Run graph.rb without arguments to get basic help:

```
Usage: ./graph.rb [-d] [-p] config.rb
    -d, --debug                      Print debugging statements
    -p, --paths                      Print paths of generated charts
```

I assume you want to first make sure the config works, then run grapher with -d to see if everything is fine.

## Rantish

There are no docs yet, but it actually works quite well. Even for the laptop version with sensors plugin being not nice and making a directory for each 'controller' - you get errors, but the graphs are exactly as you (well, I) wanted them to be. Honestly, as much as I find RRD a great database, I can't understand why making graphs is so painful - most of the stuff you have to specify when graphing could just as well be embedded in the .rdd file - .rrd files are rigid. Anyways, if you find it useful tell me!

Enjoy!
