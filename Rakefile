require 'config/initialize'

desc "runs Charyb to suck down data"
namespace :run do
  task :crawler do
    puts "Running Charyb crawler..."
    load 'script/run_crawler.rb'
  end

  task :web do
    puts "Running Charyb interface..."
    `ruby src/application.rb`
  end
end

desc "database "
namespace :db do
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
