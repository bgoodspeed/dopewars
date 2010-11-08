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
