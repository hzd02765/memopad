PROJECT_NAME = Dir.pwd.split("/").last
ENVIRONMENT_RB = 'config/environment.rb'
APPLICATION_RB = 'app/controllers/application.rb'

task :init_gettext do
	require 'fileutils'
	next if /\$KCODE = 'u'/ =~ IO.read(ENVIRONMENT_RB)
	
	FileUtils.cp ENVIRONMENT_RB, "#{ENVIRONMENT_RB}.bak"
	File.open(ENVIRONMENT_RB, 'w') do |f|
		f.puts "$KCODE = 'u'"
		f.puts IO.read(ENVIRONMENT_RB + '.bak')
		f.puts "require 'gettext/rails'"
	end
	
	FileUtils.cp APPLICATION_RB, "#{APPLICATION_RB}.bak"
	File.open(APPLICATION_RB, 'w') do |f|
		File.open("#{APPLICATION_RB}.bak", 'r').each_line do |line|
			f.puts line
			if /class ApplicationController/ =~ line
				f.puts " init_gettext '#{PROJECT_NAME}'"
			end
		end.close
	end
end

task :void_gettext do
	FileUtils.cp "#{ENVIRONMENT_RB.bak}", ENVIRONMENT_RB
	FileUtils.cp "#{APPLICATION_RB.bak}", APPLICATION_RB
end

task :load_gettext do
	require 'gettext/utils'
end

task :update_po => [:load_gettext] do
	GetText.update_pofiles PROJECT_NAME, Dir.glob('{app,config,components,lib}/**/*.{rb,rhtml}'), "#{PROJECT_NAME} 1.0.0"
	unless File.exist? 'po/ja'
		Dir.mkdir 'po/ja'
		Dir.chdir 'po/ja'
		system "msginit -i ..\\#{PROJECT_NAME}.pot -o #{PROJECT_NAME}.po"
		Dir.chdir '../..'
	end
end

task :make_mo => [:load_gettext] do
	GetText.create_mofiles true, "po", "locale"
end
