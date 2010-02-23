BASEPATH = '$HOME/Library/Application Support/iPhone Simulator/User/Applications/'

require 'rubygems'
require 'active_support'
require 'json'
require 'pp'
require 'stringio'


def all_sql_files
  file_paths = `cd "#{BASEPATH}" && egrep -Ri *\.sqlite .`.split(/\n/)
  reg = Regexp.new(/^Binary file (\.\/.*\.sqlite) matches$/)

  file_paths.each do |line|
    if match = reg.match(line)
      yield match[1]
    end
  end
end

desc 'Open project for editing'
task :edit do
  `open *.xcodeproj`
  `mate .gitignore Rakefile README Docs/`
end

desc 'Delete the database'
task :wipe do
  # todo: make this only delete one particular database instead of all
  all_sql_files do |match|
    puts "removing #{match}"
    `cd "#{BASEPATH}" && rm #{match}`
  end
end

desc 'Back up a (faulty?) database'
task :backup do
  all_sql_files do |match| 
    puts "backing up #{match}"
    backup_name = "." + match.split('.')[1] + ".backup"
    puts "to #{backup_name}"
    `cd "#{BASEPATH}" && cp #{match} #{backup_name}`
  end
end

desc 'open the database directory in Finder'
task :show_database do
  base_path = '$HOME/Library/Application\ Support/iPhone\ Simulator/User/Applications/'
  all_sql_files do |match|
    abs_path = base_path + match
    abs_path.slice!(/\/[^\/]*$/)
    puts "showing #{abs_path}"
    `open #{abs_path}`
  end
end

desc 'Overwrite the current database with a backed up database'
task :apply_backup do
  all_sql_files do |match|
    puts "overwriting #{match}"
    backup_name = "." + match.split('.')[1] + ".backup"
    puts "with #{backup_name}"
    `cd "#{BASEPATH}" && cp #{backup_name} #{match}`
  end
end
