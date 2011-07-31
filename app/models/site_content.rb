class SiteContent < ActiveRecord::Base
  belongs_to :site
  validates_presence_of :site_id, :data
end
