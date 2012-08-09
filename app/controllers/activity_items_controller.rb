class ActivityItemsController < ApplicationController


  def index

  end

  def create
    # parse the payload coming from github and build a new
    # activity item from it before sending it off to Crisply.
    ActivityItem.from_github(params[:payload]).to_crisply!
  end
end
