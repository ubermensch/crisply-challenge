class ActivityItemsController < ApplicationController

  def index
    @activity_items = ActivityItem.all
  end

  def create
    # parse the payload coming from github and build a new
    # activity item from it before sending it off to Crisply.
    @a_i = ActivityItem.from_github(params['payload'])
    @a_i.to_crisply!
    respond_to do |format|
      format.any {
        render :json => @a_i, :status => :created
      }
    end
  end
end
