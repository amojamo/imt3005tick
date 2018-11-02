require 'puppetlabs_spec_helper/rake_tasks'
require 'puppet-lint/tasks/puppet-lint'
require 'metadata-json-lint/rake_task'

exclude_paths = %w(
  vendor/**/*
  spec/**/*
  modules/**/*
  pkg/**/*
  tests/**/*
)

Rake::Task[:lint].clear
PuppetLint::RakeTask.new(:lint) do |config|
  # Pattern of files to ignore
  config.ignore_paths = exclude_paths
  # Pattern of files to check, defaults to `**/*.pp`
  config.pattern = ['manifests/**/*.pp', 'site/**/*.pp']
  # List of checks to disable
  config.disable_checks = ['140chars', 'relative', 'class_inherits_from_params_class']
  # Should the task fail if there were any warnings, defaults to false
  config.fail_on_warnings = true
  # Print out the context for the problem, defaults to false
  #config.with_context = true
  # Log Format
  #config.log_format = '%{path}:%{line}:%{check}:%{KIND}:%{message}'
end

desc 'Blabla'
task :validate do
  Dir['site/manifests/profile/*.pp'].each do |manifest|
    sh "puppet parser validate --noop #{manifest}"
  end
end

desc 'Run lint, validate, spec tests'
task :test do
  [:lint, :validate, :spec].each do |test|
    Rake::Task[test].invoke
  end
end
