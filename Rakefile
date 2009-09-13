require 'config/initialize'

require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc "loads the right environment"
task :environment do
  # nothing here yet.
  # suppose to do what config/initialize does"
end

namespace :web do
  desc "runs the web interface to help screen scrape"
  task :run do
    puts "Running Charyb interface..."
    `ruby src/application.rb`
  end
end

namespace :crawler do
  desc "runs Charyb crawler to suck down data"
  task :run do
    puts "Running Charyb crawler..."
    load 'script/run_crawler.rb'
  end
end

desc "database stuff"
namespace :db do
  desc "resets the database"
  task :reset do
    puts "Deleting the database"
    `rm -rf #{Charyb::DATASOURCES_PATH}`
  end

  desc "migrates the database"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrations")
  end
end

desc "generators"
namespace :generate do
  desc "rake generate:migration[name of migration]"
  task :migration, :name do |t, args|
    puts "Generating migration"
    class_name = args.name.gsub(/\s+/, "_")
    filename = Time.now.strftime("%Y%m%d%H%M%S") + "_" + class_name + ".rb"
    File.open(File.join(Charyb::MIGRATIONS_ROOT, filename), 'w') do |f|
      f.write %Q{
        class #{class_name.camelize} < ActiveRecord::Migration
          def self.up
          end
   
          def self.down
          end
        end}
    end
  end
end

namespace :view do
  desc "Updating view documents"  
  task :update do
    load 'script/view_update.rb'
  end
end
