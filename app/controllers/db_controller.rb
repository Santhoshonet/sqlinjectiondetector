class DbController < ApplicationController

  def reset

    Site.destroy_all
    SiteContent.destroy_all
    SqlInjectionQuery.destroy_all

    system "rake db:reset &"

    render :text =>  "done"

  end

end
