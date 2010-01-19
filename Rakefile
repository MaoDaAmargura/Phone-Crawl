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
  `mate .gitignore Rakefile stories/`
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

desc 'Update sample json movietime feed with times for today'
task :json_for_today do
  # json_file = "sample-feed.json"
  json_file = "pretty-sample-feed.json"
  out_file = "sample-feed.json"
  data = JSON.parse(File.read(json_file))

  movietimes = data['movietimes']

  movietimes.each do |movietime|
    today = Time.new.at_midnight
    original = Time.parse(movietime['time'])
    offset = original - original.at_midnight
    movietime['time'] = today + offset
  end

  File.open(out_file, 'w') do |file|
    file.puts data.to_json
  end

end

task :test do
  `cat sample.txt > test.txt`
  json_file = "test.txt"
  data = JSON.parse(File.read(json_file))

  data.each do |movietime|
    today = Time.new.at_midnight
    original = Time.parse(movietime['time'])
    offset = original - original.at_midnight
    
    p "*"* 25
    p "offset" + offset.to_s
    pp movietime
    if offset < 21600 then 
      offset += 86400 
      p "~" * 3
    end
    movietime['time'] = (today + offset).utc
    pp movietime
  end

  File.open(json_file, 'w') do |file|
    file.puts data.to_json
  end
end

task :print do
  json_file = "test.txt"
  pp JSON.parse(File.read(json_file))
end