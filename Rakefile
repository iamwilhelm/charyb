
require 'rake'
require 'rake/testtask'
require 'rake/rdoctask'

desc "loads the right environment"
task :environment do
  require 'config/initialize'
  require 'src/crawler'
end

namespace :web do
  desc "runs the web interface to help screen scrape"
  task :run => :environment do
    puts "Running Charyb interface..."
    `ruby src/application.rb`
  end
end

namespace :crawler do
  desc "runs Charyb crawler to suck down data"
  task :run => :environment do
    puts "Running Charyb crawler..."
    Charyb::Crawler.start
  end
end

desc "run tests"
task :test do
  Dir.glob(File.join("test", "*_test.rb")) do |filename|
    puts `ruby #{filename}`
  end
end
namespace :test do
end

desc "database stuff"
namespace :db do
  desc "resets the database"
  task :reset, :confirm do |t, args|
    if args.confirm.nil?
      puts("need to run 'rake db:reset[true]' to reset")
      return 
    end
    puts "Deleting the database"
    `rm -rf #{Charyb::DATASOURCES_PATH}`
    puts "Reloading the database"
    Rake::Task["db:schema:load"].invoke
  end

  desc "migrates the database"
  task :migrate => :environment do
    ActiveRecord::Base.logger = Logger.new(STDOUT)
    ActiveRecord::Migration.verbose = true
    ActiveRecord::Migrator.migrate("db/migrations")
    Rake::Task["db:schema:dump"].invoke
  end

  namespace :schema do
    desc "dumps the database schema"
    task :dump do
      puts "dumping the database schema to #{Charyb::SCHEMA_PATH}"
      File.open(Charyb::SCHEMA_PATH, 'w') do |file|
        ActiveRecord::SchemaDumper.dump(ActiveRecord::Base.connection, file)
      end
    end

    desc "loads the database schema"
    task :load do
      puts "loading the database schema from db/schema.rb"
      load(Charyb::SCHEMA_PATH)
    end
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
