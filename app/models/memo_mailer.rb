require 'nkf'

class MemoMailer < ActionMailer::Base
  def receive(mail)
    if mail.from.length == 1 && mail.from[0] == MemoPad::MAIL_FROM && NKF.nkf('--utf8', mail.subject) == 'メモ'
      lines = mail.body.split /\r?\n/
      if lines.length >= 2
        Memo.create :created_at => mail.date, :text => lines[1], :location => lines[0]
      end
    end
  end
end
