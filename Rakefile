# frozen_string_literal: true

require "bundler/gem_tasks"
require "rspec/core/rake_task"

RSpec::Core::RakeTask.new(:spec)

require "rubocop/rake_task"

########################################################################
# Rubocop tasks
########################################################################
# Option A (recommended): Keep using Bundler and run rubocop via `bundle exec`.
# This wrapper task ensures the rubocop run uses the gems from your Gemfile,
# even when you invoke `rake rubocop` (no need to remember `bundle exec rake`).
#
# You can pass extra RuboCop CLI flags with the RUBOCOP_OPTS environment variable:
#   RUBOCOP_OPTS="--format simple" rake rubocop

desc "Run rubocop under `bundle exec`"
task :rubocop do
  opts = (ENV['RUBOCOP_OPTS'] || '').split
  Bundler.with_unbundled_env do
    sh 'bundle', 'exec', 'rubocop', *opts
  end
end

task :default => [:spec, :rubocop]
