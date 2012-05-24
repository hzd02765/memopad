class CreateTable < ActiveRecord::Migration
  def self.up
	create_table :memos do |t|
		t.column :created_at, :datetime
		t.column :text, :string, :limit => 256
		t.column :location, :string, :limit => 64
	end
  end

  def self.down
	drop_table :memos
  end
end
