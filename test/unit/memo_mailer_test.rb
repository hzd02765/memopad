require File.dirname(__FILE__) + '/../test_helper'

class MemoMailerTest < Test::Unit::TestCase
  FIXTURES_PATH = File.dirname(__FILE__) + '/../fixtures'
  # CHARSET = "utf-8"
  CHARSET = "iso-2022-jp"

  include ActionMailer::Quoting

  def setup
    ActionMailer::Base.delivery_method = :test
    ActionMailer::Base.perform_deliveries = true
    ActionMailer::Base.deliveries = []

    @expected = TMail::Mail.new
    @expected.set_content_type "text", "plain", { "charset" => CHARSET }
    @expected.mime_version = '1.0'
  end
  
  def test_receive
    fixture = IO.read("#{FIXTURES_PATH}/memo_mailer/memotest")
    fixture.gsub! 'MAIL_FROM', MemoPad::MAIL_FROM
    fixture.split('----').each do |mail|
      MemoMailer.receive mail.lstrip
    end
    memos = Memo.find(:all, :conditions => "location = 'Location'")
    assert_equal 1, memos.length
    assert_equal Time.parse('Sat, 6 oct 2007 23:20:22 +0900'), memos[0].created_at
  end

  private
  
  def read_fixture(action)
    IO.readlines("#{FIXTURES_PATH}/memo_mailer/#{action}")
  end

  def encode(subject)
    quoted_printable(subject, CHARSET)
  end
end
