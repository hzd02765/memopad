class CreateAttachments < ActiveRecord::Migration
  def self.up
    create_table :attachments do |t|
      t.column :memo_id, :integer
      t.column :name, :string, :limit => 64
      t.column :size, :integer
      t.column :content_type, :string, :limit => 64
      t.column :content, :mediumblob
    end
  end

  def self.down
    drop_table :attachments
  end
end
