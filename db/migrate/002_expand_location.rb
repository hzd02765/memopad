class ExpandLocation < ActiveRecord::Migration
  def self.up
    change_column :memos, :location, :string, :limit => 256
  end

  def self.down
    change_column :memos, :location, :string, :limit => 64
  end
end
