require 'config/initialize'

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

desc "database "
namespace :db do
  desc "resets the database"
  task :reset do
    puts "Deleting the database"
    `rm -rf #{Charyb::DATASOURCES_PATH}`
  end
end

namespace :view do
  desc "Updating view documents"  
  task :update do
    load 'script/view_update.rb'
  end
end
