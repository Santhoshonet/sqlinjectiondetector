desc "Analysis with the responses"
task :analyse, :site_id, :needs => :environment do |t,args|
    site = Site.find_by_id(args.site_id)
    unless site.nil?
      base_content = site.base_html
      SiteContent.find_all_by_site_id(site.id) do |site_content|
        site_content = SiteContent.new
        response = Hash.from_xml(site_content.data)
        expected = Hash.from_xml(base_content)
        puts expected.diff(response)
      end
    end
end