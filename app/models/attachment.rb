class Attachment < ActiveRecord::Base
  validates_presence_of :name, :size, :content_type, :content
  
  belongs_to :memo
  
  METADATA_COLUMNS = 'id, memo_id, name, size, content_type'
  
  def self.metadatas(memo)
    find :all, :select => METADATA_COLUMNS, :conditions => ['memo_id = ?', memo.id]
  end
  
  def self.metadata(id)
    find id, :select => METADATA_COLUMNS
  end
end
