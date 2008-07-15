bong
    by Geoffrey Grosenbach
    boss@topfunky.com
    http://topfunky.com

== DESCRIPTION:
  
Hit your website with bong. Uses httperf to run a suite of benchmarking tests against specified urls on your site. 

Graphical output and multi-test comparisons are planned. Apache ab support may be added in the future.

== USAGE

See all options with:

  % bong --help

Generate a config file (writes to config/httperf.yml by default):

  % bong --generate 

Edit the config file with a list of servers, urls, and your preferred sample size. NOTE: Don't run this against servers you don't own!

  --- 
  uris: 
  - /
  - /pages/about
  samples: 2
  servers: 
  - localhost:3000

Run the benchmarking suite, label it 'baseline', and output the raw data to a file (writes output to log/httperf-report.yml by default):

  % bong baseline

A report will be printed to the screen and the raw data will be saved to log/httperf-report.yml (change with the --out option). It's a good idea to use a label for each test so you can compare them later and find out what the fastest implementation was. Examples: 'baseline', 'memcached-optimization', 'sql-queries', etc.

  baseline
    localhost
      /               37-56 req/sec
      /products.rss   395-403 req/sec
    example.com
      /               35-58 req/sec
      /products.rss   400-407 req/sec

View the saved report again with:

  % bong baseline -r log/httperf-report.yml

Lather, rinse, repeat.

== LIMITATIONS

* Can't access pages that require login.
* HTTP GET only.

== REQUIREMENTS

The httperf command-line tool must be installed. Get it here: 

  http://www.hpl.hp.com/research/linux/httperf/download.php

You must start a webserver (or just Mongrel). Ideally, this would be on a different machine over a fast network. You can also run bong against the local machine or (less ideally) against a remote machine over a slow network, but these will give different performance numbers and may not be accurate.

Internally, bong will

* Run a short series of 5 hits against a URL.
* Calculate the number of hits needed to run for 10 seconds, or 2 samples. You can change this in the config file, but 2 is the minimum for getting a meaningful standard deviation out of the report.
* A test will be run again.
* A short report will be displayed and the raw data will be saved for later comparison.

See http://peepcode.com/products/benchmarking-with-httperf for a full tutorial on httperf (produced by Geoffrey Grosenbach, technical editing by Zed Shaw).

== INSTALL:

* sudo gem install bong

== EXPERIMENTAL GRAPHS

After running bong a number of times, provide a visual output with time on the x axis and req/second on the y axis. Intended to show the change in performance throughout the development of a project.

Assumptions

* Each run will be named "benchmark-1216122887" where the second part can be converted to a Time class using Time.at(..)
* Runs will be displayed at equal intervals along the x axis regardless of if the time between them is uniform
* Several URLs may be incldued. rps for each one will be of a similar order of magnitude, so it makes sense to graph them together
* Not all URLs will have data in all runs. However once a url is added it will be in ALL subsequent runs

== LICENSE:

(The MIT License)

Copyright (c) 2007 Topfunky Corporation

Permission is hereby granted, free of charge, to any person obtaining
a copy of this software and associated documentation files (the
'Software'), to deal in the Software without restriction, including
without limitation the rights to use, copy, modify, merge, publish,
distribute, sublicense, and/or sell copies of the Software, and to
permit persons to whom the Software is furnished to do so, subject to
the following conditions:

The above copyright notice and this permission notice shall be
included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED 'AS IS', WITHOUT WARRANTY OF ANY KIND,
EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.
IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY
CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT,
TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE
SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
