# frozen_string_literal: true

require 'rake/testtask'
require_relative 'require_app'

task :default do
  puts `rake -T`
end

desc 'Run the unit and integration tests'
desc 'Run unit and integration tests'
Rake::TestTask.new(:spec) do |t|
  t.pattern = 'spec/tests/**/*_spec.rb'
  t.warning = false
  t.verbose = true
end

desc 'Keep rerunning tests upon changes'
task :respec do
  sh "rerun -c 'rake spec' --ignore 'coverage/*'"
end

desc 'Run web app in default (dev) mode'
task run: ['run:dev']

namespace :run do
  desc 'Run API in dev mode'
  task :dev do
    sh "rerun -c --ignore 'coverage/*' --ignore 'repostore/*' -- bundle exec puma -p 9090"
  end

  desc 'Run API in test mode'
  task :test do
    sh 'RACK_ENV=test bundle exec puma -p 9090'
  end
end

namespace :run do
  desc 'Run API in dev mode'
  task :dev do
    sh 'rerun -c "rackup -p 9090"'
  end

  desc 'Run API in test mode'
  task :test do
    sh 'RACK_ENV=test rackup -p 9090'
  end
end

desc 'Generates a 64 by secret for Rack::Session'
task :new_session_secret do
  require 'base64'
  require 'securerandom'
  secret = SecureRandom.random_bytes(64).then { Base64.urlsafe_encode64(_1) }
  puts "SESSION_SECRET: #{secret}"
end

namespace :db do
  task :config do
    require 'sequel'
    require_relative 'config/environment' # load config info
    require_relative 'spec/helpers/database_helper'

    def app = TravelRoute::App
  end

  desc 'Run migrations'
  task :migrate => :config do
    Sequel.extension :migration
    puts "Migrating #{app.environment} database to latest"
    Sequel::Migrator.run(app.db, 'db/migrations')
  end

  desc 'Wipe records from all tables'
  task :wipe => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    require_app('infrastructure')
    DatabaseHelper.wipe_database
  end

  desc 'Delete dev or test database file (set correct RACK_ENV)'
  task :drop => :config do
    if app.environment == :production
      puts 'Do not damage production database!'
      return
    end

    FileUtils.rm(TravelRoute::App.config.DB_FILENAME)
    puts "Deleted #{TravelRoute::App.config.DB_FILENAME}"
  end
end

namespace :vcr do
  desc 'delete cassette fixtures'
  task :wipe do
    sh 'rm spec/fixtures/cassettes/*.yml' do |ok, _|
      puts(ok ? 'Cassettes deleted' : 'No cassettes found')
    end
  end
end

desc 'Run application console'
task :console do
  sh 'pry -r ./load_all'
end

namespace :quality do
  only_app = 'config/ app/'

  desc 'run all static-analysis quality checks'
  task all: %i[rubocop reek flog]

  desc 'code style linter'
  task :rubocop do
    sh 'rubocop'
  end

  desc 'code smell detector'
  task :reek do
    sh 'reek'
  end

  desc 'complexiy analysis'
  task :flog do
    sh "flog -m #{only_app}"
  end
end
