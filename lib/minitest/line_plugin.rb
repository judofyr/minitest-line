module Minitest
  def self.plugin_line_options(opts, options)
    opts.on '-l', '--line N', Integer, "Run test at line number" do |lineno|
      options[:line] = lineno
    end
  end

  def self.plugin_line_init(options)
    exp_line = options[:line]
    if !exp_line
      reporter.reporters << LineReporter.new
      return
    end

    methods = Runnable.runnables.flat_map do |runnable|
      runnable.runnable_methods.map do |name|
        [name, runnable.instance_method(name)]
      end
    end.uniq

    current_filename = nil
    tests = {}

    methods.each do |name, meth|
      next unless loc = meth.source_location
      current_filename ||= loc[0]
      next unless current_filename == loc[0]
      tests[loc[1]] = name
    end

    _, main_test = tests.sort_by { |k, v| -k }.detect do |line, name|
      exp_line >= line
    end

    raise "Could not find test method after line #{exp_line}" unless main_test

    options[:filter] = main_test
  end

  class LineReporter < Reporter
    def initialize(*)
      super
      @failures = []
    end

    def record(result)
      if !result.skipped? && !result.passed?
        @failures << result
      end
    end

    def report
      return unless @failures.any?
      io.puts
      io.puts "Focus on failing tests:"
      @failures.each do |res|
        meth = res.method(res.name)
        file, line = meth.source_location
        if file
          io.puts "$ ruby #{file} -l #{line}"
        end
      end
    end
  end

  def self.plugin_line_inject_reporter
  end
end

