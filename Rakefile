require 'rubygems'
require 'rake'

require 'spec/rake/spectask'
Spec::Rake::SpecTask.new(:spec) do |spec|
  spec.libs << 'spec'
  spec.spec_files = FileList['spec/**/*_spec.rb']
  spec.spec_opts << '-O spec/spec.opts'
end

task :default => :spec