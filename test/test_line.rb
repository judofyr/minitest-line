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

Minitest::Runnable.runnables.delete(LineExample)

describe "Minitest::Line" do
  def run_class(klass, args = [])
    Minitest::Runnable.stub :runnables, [klass] do
      $stdout = io = StringIO.new
      Minitest.run(args)
      $stdout = STDOUT
      io.string
    end
  end

  it "finds tests by line number" do
    (9..12).each do |line|
      output = run_class LineExample, ['--line', line.to_s]
      assert_match /1 runs/, output
      assert_match /:hello/, output
      refute_match /:world/, output
    end

    (13..16).each do |line|
      output = run_class LineExample, ['--line', line.to_s]
      assert_match /1 runs/, output
      assert_match /:world/, output
      refute_match /:hello/, output
    end
  end

  it "prints failing tests after test run" do
    output = run_class LineExample
    assert_match /Focus on failing tests:/, output
    assert_match /#{File.basename(__FILE__)} -l 17/, output
    refute_match /-l 21/, output
  end

  if __FILE__.start_with?("/")
    it "shows focus relative to pwd" do
      dir = File.dirname(__FILE__)
      Dir.chdir(dir) do
        output = run_class LineExample
        assert_match "ruby #{File.basename(__FILE__)} -l 17", output
      end
    end
  end

  it "fails when given a line before any test" do
    assert_raises(RuntimeError) do
      run_class LineExample, ['--line', '8']
    end
  end

  it "runs last test when given a line after last test" do
    output = run_class LineExample, ['--line', '80']
    assert_match /1 runs/, output
    assert_match /1 skip/, output
  end
end

