class AddTableDefault < ActiveRecord::Migration
  def self.up
    add_column :imported_tables, :default_dim, :string, :limit => 100, :null => false, :default => ""
  end
  
  def self.down
    remove_column :imported_tables, :default_dim
  end
end
