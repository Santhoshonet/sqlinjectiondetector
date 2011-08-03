class SiteContent < ActiveRecord::Base
  belongs_to :site
  has_one :sql_injection_query
  validates_presence_of :site_id, :data
end
