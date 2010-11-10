require 'rake'

$dry_run = false
$chatty = false

all_files = FileList['lib/**/*.rb']

files_to_exclude = [ 
  'lib/game_requirements.rb',
  'lib/game_settings.rb'
]

working_files = all_files - files_to_exclude

newline ='
'

all_dir_names = working_files.collect {|f| File.dirname(f) }
dir_names = all_dir_names.uniq.sort

spec_dir_names = dir_names.collect {|name| name.gsub('lib','spec')}
dirs = spec_dir_names.select {|name| !File.exists?(name)}
dirs_to_create = dirs.sort {|d1, d2| d1.length <=> d2.length}


dirs_to_create.each {|dir|
  puts "creating directory: #{dir}? #{!$dry_run}" if $chatty
  FileUtils::mkdir_p(dir) unless $dry_run
}


working_specs = working_files.collect{|name| name.gsub('lib','spec').gsub('.rb','_spec.rb') }
specs_to_create = working_specs.select{|name| !File.exists?(name)}

spec_template =<<EOF

require 'spec/rspec_helper'

describe %s do
  before(:each) do
    @%s = %s.new
  end

  it "should be described" do
    fail
  end
end
EOF



def camelize(str)
  str.gsub(/\/(.?)/) { "::#{$1.upcase}" }.gsub(/(?:^|_)(.)/) { $1.upcase }
end


specs_to_create.each {|spec_name|
  spec_class_var_name = File.basename(spec_name, '.rb').gsub('_spec','')
  spec_class_name = camelize(spec_class_var_name)
  puts "make a spec in file #{spec_name} describing #{spec_class_name} with instance var #{spec_class_var_name}" if $chatty
  spec_content = format(spec_template, spec_class_name, spec_class_var_name, spec_class_name)
  File.open(spec_name, "w") {|f| f.write(spec_content)} unless $dry_run
}

puts "Created #{dirs_to_create.size} directories"
puts "Created #{specs_to_create.size} new specs"
