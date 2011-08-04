class CreateSqlInjectionQueries < ActiveRecord::Migration
  def self.up
    create_table :sql_injection_queries do |t|
      t.text :query
      t.timestamps
    end
  end

  def self.down
    drop_table :sql_injection_queries
  end
end
