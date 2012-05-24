env = ENV['RAILS_ENV'] || 'development'
database = "memopad_#{env}"

task :connect_db => [:environment] do
	ActiveRecord::Base.establish_connection(
		:adapter => 'mysql',
		:host => 'localhost',
		:username => 'root',
		:database => 'mysql'
	)
end

task :setup_db => [:connect_db] do
	ActiveRecord::Schema.define do
		create_database database
	end
end

task :destroy_db => [:connect_db] do
	ActiveRecord::Schema.define do
		drop_database database
	end
end