class SqlInjectionQuery < ActiveRecord::Base
  belongs_to :site_content
  validates_presence_of :query
  #validates_uniqueness_of :query
end
