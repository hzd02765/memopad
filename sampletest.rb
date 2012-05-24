require 'test/unit'
class SampleTest < Test::Unit::TestCase
  def setup
    puts 'setup'
  end
  def teardown
    puts 'teardown'
  end
  def test_sum
    puts 'test_sum'
    assert_equal 3, 1 + 2
  end
  def test_divide
    puts 'test_divide'
    assert_equal 1.0, 2.0 / 2
  end
end