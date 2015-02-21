require 'pathname'

module Minitest
  module Line
    class << self
      def tests_with_lines
        target_file = $0
        methods_with_lines(target_file).concat describes_with_lines(target_file)
      end

      private

      def methods_with_lines(target_file)
        runnables.flat_map do |runnable|
          rname = runnable.name
          runnable.runnable_methods.map do |name|
            file, line = runnable.instance_method(name).source_location
            next unless file == target_file
            test_name = (rname ? "#{rname}##{name}" : name)
            [test_name, line]
          end
        end.uniq.compact
      end

      def describes_with_lines(target_file)
        runnables.map do |runnable|
          next unless caller = runnable.instance_variable_get(:@minitest_line_caller)
          next unless line = caller.detect { |line| line.include?(target_file) }
          ["/#{Regexp.escape(runnable.name)}/", line[/:(\d+):in/, 1].to_i]
        end.compact
      end

      def runnables
        Minitest::Runnable.runnables
      end
    end
  end

  def self.plugin_line_options(opts, options)
    opts.on '-l', '--line N', Integer, "Run test at line number" do |lineno|
      options[:line] = lineno
    end
  end

  def self.plugin_line_init(options)
    unless exp_line = options[:line]
      reporter.reporters << LineReporter.new
      return
    end

    tests = Minitest::Line.tests_with_lines

    filter, _ = tests.sort_by { |n, l| -l }.detect { |n, l| exp_line >= l }

    raise "Could not find test method before line #{exp_line}" unless filter

    options[:filter] = filter
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
      pwd = Pathname.new(Dir.pwd)
      @failures.each do |res|
        meth = res.method(res.name)
        file, line = meth.source_location
        if file
          file = Pathname.new(file)
          file = file.relative_path_from(pwd) if file.absolute?
          output = "ruby #{file} -l #{line}"
          output = "\e[31m#{output}\e[0m" if $stdout.tty?
          io.puts output
        end
      end
    end
  end

  def self.plugin_line_inject_reporter
  end
end
