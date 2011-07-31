class CreateSiteContents < ActiveRecord::Migration
  def self.up
    create_table :site_contents do |t|
      t.text :data
      t.integer :response_code
      t.integer :site_id
      t.timestamps
    end
  end

  def self.down
    drop_table :site_contents
  end
end
