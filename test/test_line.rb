$LOAD_PATH << File.expand_path('../../lib', __FILE__)

require 'stringio'
require 'minitest'
require 'minitest/autorun'
require 'minitest/mock'

class LineExample < Minitest::Test
  def test_hello
    p :hello
  end

  def test_world
    p :world
  end

  def test_failure
    flunk
  end

  def test_skip
    skip
  end
end

class Line2Example < Minitest::Test
  def test_hello
    p :hello
  end
end

DescribeExample = describe "DescribeExample" do
  it "hello" do
    p :hello
  end

  describe "here" do
    describe "comes" do
      it "the nesting" do
        p :nested
      end

      it "is amazing" do
        p :amazing
      end
    end
  end

  it "world" do
    p :world
  end
end

Minitest::Runnable.runnables.delete(LineExample)
Minitest::Runnable.runnables.delete(Line2Example)
describe_examples = Minitest::Runnable.runnables.select { |c| c == DescribeExample || c < DescribeExample }
Minitest::Runnable.runnables.delete_if { |c| describe_examples.include?(c) }

describe "Minitest::Line" do
  def pending
    yield
  rescue Minitest::Assertion
    skip
  else
    raise "It works!"
  end

  def run_class(klasses, args = [])
    Minitest::Runnable.stub :runnables, klasses do
      $stdout = io = StringIO.new
      Minitest.run(args)
      $stdout = STDOUT
      io.string
    end
  end

  it "finds tests by line number" do
    [*9..12, *27..29].each do |line|
      output = run_class [LineExample, Line2Example], ['--line', line.to_s]
      assert_match /1 runs/, output
      assert_match /:hello/, output
      refute_match /:world/, output
    end

    (13..16).each do |line|
      output = run_class [LineExample], ['--line', line.to_s]
      assert_match /1 runs/, output
      assert_match /:world/, output
      refute_match /:hello/, output
    end
  end

  it "prints failing tests after test run" do
    output = run_class [LineExample]
    assert_match /Focus on failing tests:/, output
    assert_match /#{File.basename(__FILE__)} -l 17/, output
    refute_match /-l 21/, output
  end

  if __FILE__.start_with?("/")
    it "shows focus relative to pwd" do
      dir = File.dirname(__FILE__)
      Dir.chdir(dir) do
        output = run_class [LineExample]
        assert_match "ruby #{File.basename(__FILE__)} -l 17", output
      end
    end
  end

  it "fails when given a line before any test" do
    assert_raises(RuntimeError) do
      run_class [LineExample], ['--line', '8']
    end
  end

  it "runs last test when given a line after last test" do
    output = run_class [LineExample], ['--line', '80']
    assert_match /1 runs/, output
    assert_match /1 skip/, output
  end

  it "runs tests declared with it" do
    output = run_class describe_examples, ['--line', '33']
    assert_match /1 runs/, output
    assert_match /:hello/, output
    refute_match /:world/, output
  end

  it "runs tests declared with it inside nested describes" do
    output = run_class describe_examples, ['--line', '43']
    assert_match /1 runs/, output
    assert_match /:amazing/, output
    refute_match /:nesting/, output
  end

  it "runs tests declared with describe" do
    pending do
      output = run_class describe_examples, ['--line', '38']
      assert_match /2 runs/, output
      assert_match /:nested/, output
      assert_match /:amazing/, output
      refute_match /:hello/, output
      refute_match /:world/, output
    end
  end
end

