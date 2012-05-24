task :hello do
	puts 'Hello World !'
end

task :goodbye => :hello do
	puts 'Goodbye !'
end
