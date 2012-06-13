module Net
  class POPMail
  
    def initialize(s)
      @data = s
      @deleted = false
    end
    
    def pop(dest = '')
      dest << @data
    end
    
    def delete
      @deleted = true
    end
    
    def deleted?
      @deleted
    end
  end
  
  class POP3
    FIXTURES_PATH = File.dirname(__FILE__) + '/../../../fixtures'
    
    def self.APOP(use_apop)
      self
    end
    
    def self.instance
      @@pop3
    end
    
    def initialize(fixturename, &start_check)
      fixture = IO.read("#{FIXTURES_PATH}/memo_mailer/#{fixturename}")
      mails = (fixture.gsub 'MAIL_FROM', MemoPad::MAIL_FROM).split('----')
      @mails = mails.collect do |mail|
        POPMail.new mail.lstrip
      end
      @@pop3 = self
      @start_check = start_check
    end
    
    def self.start(server, port, account, password)
      @@pop3.start server, port, account, password
      yield @@pop3
    end
    
    def start(server, port, account, password)
      @start_check.call server, port, account, password
    end
    
    attr_reader :mails
    
    def each_mail(&proc)
      @mails.each do |mail|
        yield mail
      end
    end
    
    @@pop3 = nil
  end
end