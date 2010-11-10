# 
# To change this template, choose Tools | Templates
# and open the template in the editor.
 

require 'rubygems'
require 'rake'
require 'rake/clean'
require 'rake/gempackagetask'
require 'rake/rdoctask'
require 'rake/testtask'
require 'spec/rake/spectask'

spec = Gem::Specification.new do |s|
  s.name = 'dopewars'
  s.version = '0.0.1'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README', 'LICENSE']
  s.summary = 'Your summary here'
  s.description = s.summary
  s.author = ''
  s.email = ''
  # s.executables = ['your_executable_here']
  s.files = %w(LICENSE README Rakefile) + Dir.glob("{bin,lib,spec}/**/*")
  s.require_path = "lib"
  s.bindir = "bin"
end

Rake::GemPackageTask.new(spec) do |p|
  p.gem_spec = spec
  p.need_tar = true
  p.need_zip = true
end

Rake::RDocTask.new do |rdoc|
  files =['README', 'LICENSE', 'lib/**/*.rb']
  rdoc.rdoc_files.add(files)
  rdoc.main = "README" # page to start on
  rdoc.title = "dopewars Docs"
  rdoc.rdoc_dir = 'doc/rdoc' # rdoc output folder
  rdoc.options << '--line-numbers'
end

Rake::TestTask.new do |t|
  t.test_files = FileList['test/**/*.rb']
end

Spec::Rake::SpecTask.new do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.spec_opts << ['--backtrace']
  t.libs << Dir["lib"]
end

require 'rake'
require 'spec/rake/verify_rcov'
require 'spec/rake/spectask'

desc "Run all examples with RCov"
Spec::Rake::SpecTask.new('examples_with_rcov') do |t|
  t.spec_files = FileList['spec/**/*.rb']
  t.rcov = true
  t.rcov_opts = ['--exclude', 'spec', '--exclude', '/var/lib']
end

RCov::VerifyTask.new(:verify_rcov => 'examples_with_rcov') do |t|
  t.threshold = 100.0
  t.index_html = 'coverage/index.html'
end

require 'roodi'
require 'roodi_task'
desc "Analyze for code best practices"
RoodiTask.new 'verify_roodi', ['lib/**/*.rb']


require 'reek'
require 'reek/rake/task'

desc "Analyze for code smells"
Reek::Rake::Task.new(:verify_reek) do |t|
  t.fail_on_error = true
end

require 'flog'
desc "Analyze for code complexity"
task :verify_flog do
  flog = Flog.new
  files = Flog.expand_dirs_to_files(['lib'])
  files_to_ignore = ["lib/game_requirements.rb"]
  files -= files_to_ignore
  threshold = 40

  flog.flog(*files)
  
  bad_methods = flog.totals.select do |name, score|
    score > threshold
  end
  bad_methods.sort { |a,b| a[1] <=> b[1] }.each do |name, score|
    puts "%8.1f: %s" % [score, name]
  end

  raise "#{bad_methods.size} methods have a flog complexity > #{threshold}" unless bad_methods.empty?
end

require 'flay'

desc "Analyze for code duplication"
task :verify_flay do
  threshold = 20
  flay = Flay.new({:fuzzy => false, :verbose => false, :mass => threshold})
  files = Flay.expand_dirs_to_files(['lib'])
  puts "got files: #{files.join(',')}"
  flay.process(*files)

  flay.report

  raise "#{flay.masses.size} chunks of code have a duplicate mass > #{threshold}" unless flay.masses.empty?
end

task :verify => [:verify_rcov, :verify_flay, :verify_flog, :verify_reek, :verify_roodi ]

require 'cucumber'
require 'cucumber/rake/task'

Cucumber::Rake::Task.new(:features) do |t|
  
  t.cucumber_opts = "features --format pretty"

end

Cucumber::Rake::Task.new(:feature) do |t|
  t.methods.sort.join(",")
  t.cucumber_opts = "features --format pretty"

end

task :default => [:spec, :features]


#Integrate with:
#heckle :  spec spec/.../..._spec.rb --heckle ClassNameToVerify
#reek :  reek lib/**/*.rb
#roodi :  roodi lib/**/*.rb
#flog :  flog lib/**/*.rb
#flay :  flay lib/**/*.rb
