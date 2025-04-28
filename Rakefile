require 'rake'
require 'rake/testtask'
require 'rspec/core/rake_task'

RSpec::Core::RakeTask.new(:spec)

task default: :spec

desc 'Run all tests and generate coverage report'
task :test do
  Rake::Task['spec'].invoke
end

desc 'Run RuboCop'
task :rubocop do
  sh 'rubocop'
end

desc 'Run all checks'
task :check do
  Rake::Task['rubocop'].invoke
  Rake::Task['test'].invoke
end 