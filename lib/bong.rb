require 'yaml'
require 'logger'

##
# A tool for running httperf against a website. Documentation coming soon.

class Bong
  VERSION = '0.0.2'

  ##
  # Generate a sample config file.

  def self.generate(config_yml_path)
    config_data = {
      'servers' => ['localhost:3000'],
      'uris'    => ['/', '/pages/about'],
      'samples' => 2,
      'concurrency' => 1,
      'cookie' => ''
    }

    if File.exist?(config_yml_path)
      puts("A config file already exists at '#{config_yml_path}'.")
      exit
    end

    File.open(config_yml_path, 'w') do |f|
      f.write config_data.to_yaml
    end
  end

  def initialize(config_yml_path, label)
    unless File.exist?(config_yml_path)
      puts <<-MESSAGE

      A config file could not be found at '#{config_yml_path}'.

      Please generate one with the -g option.

      MESSAGE
      exit
    end

    @config       = YAML.load(File.read(config_yml_path))
    @label        = label
    @stats        = {}

    @logger       = Logger.new(STDOUT)
    @logger.level = Logger::DEBUG
    
    @logger.info "Running suite for label '#{@label}'"
  end

  def run
    servers.each do |server, port|
      port ||= 80
      @stats[server] = {}
      uris.each do |uri|
        run_benchmark(server, port, uri)
      end
    end
  end


  def graph_report(graph_path, report_yml_path)
    # Require gruff here so people can run the rest of the app without gruff.
    require 'gruff'
    
    @report = YAML.load(File.read(report_yml_path))

    # Remove any with no date
    @report.reject! { |name, data| name.split("-").size != 2 }

    number_of_times = @report.size
    
    inverted_report = { }
    
    @report.each do |name, data|
      report_time = Time.at(name.split("-").last.to_i)
      date_time = report_time.strftime("%d/%m %H:%M")
      
      data.each do |host, urls|
        urls.each do |url, payload|
          inverted_report[url] ||= { }
          inverted_report[url][date_time] = payload['avg'] || nil
        end
      end      
    end
    
    inverted_report.each do |url, payload|
      inverted_report[url][:array] = inverted_report[url].to_a.sort.map{|ele| ele.last}
      missing_times = number_of_times - inverted_report[url][:array].size
      inverted_report[url][:array] = Array.new(missing_times) + inverted_report[url][:array]
    end
      
    g = Gruff::Line.new
    g.title = "Requests per second" 

    inverted_report.each do |url, payload|
      g.data(url, inverted_report[url][:array])
    end
    
    g.write(graph_path)
  end
  
  def load_report(report_yml_path, label=nil)
    @report = YAML.load(File.read(report_yml_path))
    label = label || @label || @report.keys.first
    @stats = @report[label]
  end

  def report
    length_of_longest_uri = uris.inject(0) { |length, uri| uri_length = uri.length; (uri_length > length ? uri_length : length) }
    
    output = ["\n#{@label}"]
    servers.each do |server, port|
      output << "  #{server}"
      uris.each do |uri|
        output << "    #{format_string(uri, length_of_longest_uri)} #{format_rounded(@stats[server][uri]['avg_low'])}-#{format_rounded(@stats[server][uri]['avg_high'])} req/sec"
      end
    end
    output.join("\n")
  end

  def save_report(path)
    @all_stats = {}
    if File.exist?(path)
      @all_stats = YAML.load(File.read(path))
    end
    
    @all_stats[@label] = @stats
    
    File.open(path, 'w') do |f|
      f.write @all_stats.to_yaml
    end
  end

  protected

  ##
  # A list of servers and ports from the config file.

  def servers
    @config['servers'].map { |server| server.split(/:/) }
  end

  def uris
    @config['uris']
  end

  def run_benchmark(server, port, uri)
    until (sufficient_sample_size?(server, uri) && no_errors?)
      increase_num_conns(server, uri)
      exec_command(server, port, uri, @num_conns)
      @stats[server][uri] = parse_results
    end
  end

  # TODO Extract to use AB instead
  def exec_command(server, port, uri, num_conns)
    @logger.info "Sending #{@num_conns} hits to #{server}:#{port}#{uri}"
    cmd = "httperf --server #{server} --port #{port} --uri #{uri} --num-conns #{num_conns}"
    @output = `#{cmd}`
  end

  # TODO Extract to use AB instead
  def parse_results
    stat = {}

    # Total: connections 5 requests 5 replies 5 test-duration 0.013 s
    stat['duration'] = @output.scan(/test-duration ([\d.]+)/).flatten.first.to_f

    # Reply rate [replies/s]: min 0.0 avg 0.0 max 0.0 stddev 0.0 (0 samples)
    (stat['min'], stat['avg'], stat['max'], stat['stddev'], stat['samples']) = @output.scan(/Reply rate \[replies\/s\]: min ([\d.]+) avg ([\d.]+) max ([\d.]+) stddev ([\d.]+) \((\d+) samples\)/).flatten.map { |i| i.to_f }

    # Reply status: 1xx=0 2xx=5 3xx=0 4xx=0 5xx=0
    (stat['1xx'], stat['2xx'], stat['3xx'], stat['4xx'], stat['5xx']) = @output.scan(/Reply status: 1xx=(\d+) 2xx=(\d+) 3xx=(\d+) 4xx=(\d+) 5xx=(\d+)/).flatten.map { |i| i.to_f }

    stat['avg_low']  = stat['avg'].to_f - 2.0 * stat['stddev'].to_f
    stat['avg_high'] = stat['avg'].to_f + 2.0 * stat['stddev'].to_f

    stat
  end

  def sufficient_sample_size?(server, uri)
    @stats[server][uri]['samples'] >= @config['samples'].to_f
  rescue
    false
  end

  def no_errors?
    # TODO
    true
  end

  def increase_num_conns(server, uri)
    samples             = @stats[server][uri]['samples']
    duration            = @stats[server][uri]['duration']
    target_samples      = @config['samples']

    seconds_per_request = (duration / @num_conns.to_f) # 0.02
    adjusted_conns      = (target_samples * 5.0) / seconds_per_request # 500

    # Increase the connections by the factor and a bit more.
    @num_conns          = (adjusted_conns * 1.2).to_i
  rescue
    @num_conns = 5
    nil
  end

  ##
  # Return a string with rounding for display.
  #
  # Small numbers will have a decimal point. Larger numbers will be shown
  # as plain integers.

  def format_rounded(number)
    if number > 20
      number.to_i
    else
      sprintf('%0.1f', number)
    end
  end

  def format_string(string, length)
    sprintf "%-#{length + 2}s", string
  end

end
