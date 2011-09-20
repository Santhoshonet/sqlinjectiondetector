desc "Injection sql scripts"
require "sqlinjection"
include Sql_injection_module
task :injection, :site_id, :needs => :environment do |t,args|
    site = Site.find_by_id(args.site_id)
    unless site.nil?
      perform(site)
      #system "rake analyse[#{args.site_id}]  --trace &"
    end
end

