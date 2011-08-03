class CreateSites < ActiveRecord::Migration
  def self.up
    create_table :sites do |t|
      t.string :url
      t.text :base_html
      t.boolean :status
      t.string :comment
      t.boolean :is_http_authenticated
      t.integer :response_code
      t.boolean :is_it_root_site_url
      t.text :cookie
      t.timestamps
    end
  end

  def self.down
    drop_table :sites
  end
end
