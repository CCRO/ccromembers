# for usage: ruby timecard.rb --help

require 'rubygems'

require 'optparse'

# This requires the 'cyberfox-gchart' gem (0.5.4), as the standard
# gchart gem is woefully broken for this kind of graph.  Broken to the
# point that it's an inherent design choice that doesn't work well for
# this kind of chart.  I'm sure that the cyberfox-gchart gem won't
# work well for many kinds of charts, as well.

# stolen from http://github.com/cyberfox/snippets/blob/master/ruby/timecard.rb
# inspired by http://dustin.github.com/2009/01/11/timecard.html
# forked from http://gist.github.com/240975

require 'gchart'

# Use the chronic gem to parse times
require 'chronic'

require 'time'

class TimeCard
  def initialize(opts)
    @path             = "."
    @branch           = "master"
    @since            = Time.now - 30*24*60*60
    @chart_width      = 800
    @chart_height     = 300
    @chart_color      = "000000"
    @chart_fill_color = "efefef"
    @launch           = false

    OptionParser.new do |opts|
      opts.banner = "Usage: #{__FILE__} [options]"

      opts.on("-b BRANCH", "--branch BRANCH", String, "Branch to process [default: master]") do |branch|
        @branch = branch
      end

      opts.on("-o OUTPUTFILE", "--outputfile OUTPUTFILE", String, "Output file") do |outputfile|
        @outputfile = outputfile
      end

      opts.on("-p GITPATH", "--path GITPATH", String, "Path containing git project [default: current directory]") do |path|
        @path = path
      end

      opts.on("-s SINCE", "--since SINCE", String, "Oldest time to scan [default: 30 days ago]") do |since|
        @since = Chronic.parse(since) rescue nil
      end

      opts.on("-w WIDTH", "--width WIDTH", Integer, "Chart width [default: #{@chart_width}]") do |width|
        @chart_width = width
      end

      opts.on("-h HEIGHT", "--height HEIGHT", Integer, "Chart height [default: #{@chart_width}]") do |height|
        @chart_height = height
      end

      opts.on("-c CHARTCOLOR", "--color CHARTCOLOR", String, "Chart color [default: #{@chart_color}]") do |color|
        @chart_color = color
      end

      opts.on("-f FILLCOLOR", "--fillcolor FILLCOLOR", String, "Chart fill (background) color [default: #{@chart_fill_color}]") do |color|
        @chart_fill_color = color
      end

      opts.on("-a AUTHOR", "--author AUTHOR", String, "Git author filter (see git-log --author docs) [default: all authors]") do |author|
        @author = author
      end

      opts.on("-l", "--launch", "launch the image file when generated") do |launch|
        @launch = launch
      end
    end.parse!

    errors = []
    errors << "You must specifiy a branch." unless @branch
    errors << "You must specifiy an output file." unless @outputfile
    errors << "You must specifiy a git directory." unless @path
    errors << "You must specifiy a duration." unless @since

    @since = @since.to_i

    unless errors.empty?
      puts errors.join(" ")
      exit
    end
  end

  def generate
    Dir.chdir(@path) if @path

    # We pull the dates in ISO 8601 format so we can see the
    # time in the local time of the committer and use the date
    # and hour locally to represent what part of the day the
    # commit occurred, otherwise we'd be in GMT or local time
    author_date_iso_8601_format = '%ai'
    git_log_command = "git log #{@branch} --pretty=format:#{author_date_iso_8601_format} --since=#{@since}"
    git_log_command << " --author=#{@author}" if @author

    puts "Executing #{git_log_command}"
    log = `#{git_log_command}`.split("\n")

    count = (1..7).map { [0]*24 }

    counts = Hash.new(0)
    log.each do |commit_time|
      logtime = parse_iso_8601(commit_time)
      index   = [logtime.wday,logtime.hour]
      counts[index] = counts[index] + 1
    end

    make_timecard(counts)
    launch_if_specified
  end

  private
    def launch_if_specified
      system("open #{@outputfile}") if @launch
    end

    def parse_iso_8601(iso_8601_time_string)
      # 2009-12-01 23:42:07 -0600
      if iso_8601_time_string =~ /(\d{4})-(\d{2})-(\d{2}) (\d{2}):(\d{2}):(\d{2})/
        year,month,day,hour,minute,second = $1,$2,$3,$4,$5,$6
        return Time.local(year,month,day,hour,minute,second)
      else
        raise "Unparsable iso 8601 time: #{iso_8601_time_string}"
      end
    end

    def make_timecard(counts)
      xd    = []
      yd    = []
      sizes = []

      counts.each do |wday_hour,count|
        next if count == 0
        xd << wday_hour.last
        yd << wday_hour.first + 1
        sizes << count
      end

      if sizes.empty?
        puts "No data to chart"
        @launch = false
        return
      end

      GChart.encoding = :text

      chart = GChart.scatter do |g|
        g.data = [xd, yd, sizes]

        g.axis(:left) do |axis_left|
          axis_left.labels = ['', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', '']
        end

        g.axis(:bottom) do |axis_right|
          axis_right.labels = ['', "12am"] + (1..11).to_a + ["12pm"] + (1..11).to_a + ['']
        end

        x_min    = -1
        x_max    = 24
        y_min    = 0
        y_max    = 8
        size_min = 0

        fill_type  = 'bg'
        fill_style = 's' # solid
        fill_color = @chart_fill_color

        marker_type           = 'o' # circle
        marker_color          = @chart_color
        marker_data_set_index = 0
        marker_data_point     = '-1'
        marker_data_size      = '25.0'

        g.extras = { 'chm' => "#{marker_type},#{marker_color},#{marker_data_set_index},#{marker_data_point},#{marker_data_size}", 'chds' => "#{x_min},#{x_max},#{y_min},#{y_max},#{size_min},#{sizes.max}", 'chf' => "#{fill_type},#{fill_style},#{fill_color}" }

        g.colors = [ marker_color ]
        g.width  = @chart_width
        g.height = @chart_height
      end

      puts chart.to_url
      chart.write(@outputfile)
    end
end
  
TimeCard.new(ARGV).generate
