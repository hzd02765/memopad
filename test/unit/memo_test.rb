require File.dirname(__FILE__) + '/../test_helper'

class MemoTest < Test::Unit::TestCase
  fixtures :memos

  # Replace this with your real tests.
  # def test_truth
    # assert true
  # end
  def test_location_length
    memos(:one).location = '+' * 256
    assert memos(:one).valid?, 'for 256 chars'
    memos(:one).location = '+' * 257
    assert !memos(:one).valid?, 'for 257 chars'
  end

  def test_read_bookmarks
    a = Memo.bookmarks
    assert_equal 2, a.size
    assert_equal 5, a[0].id
    assert_equal 3, a[1].id
  end
end
