class Memo < ActiveRecord::Base
	validates_presence_of :text, :location
	validates_length_of :location, :maximum => 256
  
  has_many :attachments, :select => Attachment::METADATA_COLUMNS
  has_many :files, :class_name => 'Attachment', :select => 'id, name, content'
  
  def self.bookmarks
    find :all, :conditions => "location like 'http://%'", :order => "created_at DESC"
  end
end