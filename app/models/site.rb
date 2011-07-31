class Site < ActiveRecord::Base
  has_many :site_contents
  validates_presence_of :url, :message =>  "input url"
  #validates_uniqueness_of :url , :message =>  "url already exists"
end
