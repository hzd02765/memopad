require File.dirname(__FILE__) + '/../test_helper'

class AttachmentTest < Test::Unit::TestCase
  fixtures :attachments
  fixtures :memos

  # Replace this with your real tests.
  
  # def test_truth
    # assert true
  # end
  
  Content = 'Hello World !'
  Filename = 'hello.txt'
  ContentType = 'text/plain'
    
  def test_create
    attachment = Attachment.new :name => Filename, 
                  :size => Content.length, 
                  :content_type => ContentType, 
                  :content => Content
    assert attachment.valid?
    validates_one_by_one attachment
  end

  def test_metadatas
    a = Attachment.metadatas memos(:one)
    assert_equal 2, a.size
    assert_equal memos(:one).id, a[0].memo_id
    assert_equal memos(:one).id, a[1].memo_id
    assert !a[0].has_attribute?(:content)
    assert !a[1].has_attribute?(:content)
  end
  
  def test_metadata
    a = Attachment.metadata attachments(:two).id
    assert_equal attachments(:two).id, a.id
    assert !a.has_attribute?(:content)
  end
  
  def test_relationship
    memo = Memo.find memos(:one).id
    assert_equal 2, memo.attachments.length
    assert_equal attachments(:one).id, memo.attachments[0].id
    assert_equal attachments(:three).id, memo.attachments[1].id
    assert !memo.attachments[0].has_attribute? (:content)
  end
  
  def test_norelationship
    memo = Memo.find memos(:three).id
    assert_equal 0, memo.attachments.length
  end
  
  def test_read_memo
    a = Attachment.metadata attachments(:two).id
    assert_equal memos(:two).text, a.memo.text
  end
  
  def test_files
    memo = Memo.find memos(:one).id
    assert_equal 2, memo.files.length
    assert_equal attachments(:one).content, memo.files[0].content
    assert_equal attachments(:three).content, memo.files[1].content
    memo = Memo.find memos(:three).id
    assert memo.files.empty?
  end
  
  private
  
  def validates_one_by_one(attachment)
    [
      [:content, Content],
      [:content_type, ContentType],
      [:size, Content.length],
      [:name, Filename]
    ].each do |column, value|
      attachment[column] = nil
      assert !attachment.valid?
      attachment[column] = value
    end
  end
end
