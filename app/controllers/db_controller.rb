class DbController < ApplicationController
  def reset
    system "rake db:reset &"
    render :text =>  "done"
  end
end
