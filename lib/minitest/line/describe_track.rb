module Minitest
  module Line
    module DescribeTrack
      def describe(*args, &block)
        klass = super
        klass.instance_variable_set(:@minitest_line_caller, caller[0..5])
        klass
      end
    end
  end
end

Object.send(:include, Minitest::Line::DescribeTrack)
