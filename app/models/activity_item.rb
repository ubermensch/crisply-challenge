class ActivityItem < ActiveRecord::Base
  attr_accessible :text, :guid, :type
  validates :text, :guid, :presence => true

  CRISPLY_API = {
    :base => 'http://frankhmeidan.crisply.com/timesheet/api',
    :api_token => 'jrt1O6bumuGw2K04hD0J'

  }

  # Builds a new ProxiedRequest object from the given
  # github webhook JSON payload
  def self.from_github(json_payload)
    payload = JSON.parse(json_payload)
    p_r = ActivityItem.new(:text => "Push made to #{payload[:repository][:name]} GitHub repo")
  end

  def to_crisply!
    xml_payload = self.to_xml(:skip_instruct => true, :only => [:text, :guid])
    response = HTTParty.post('http://frankhmeidan.crisply.com/timesheet/api/activity_items.xml',
                  :body => xml_payload,
                  :basic_auth => {:username => 'jrt1O6bumuGw2K04hD0J', :password => ''},
                  :headers => {'Content-Type' => 'application/xml; charset=UTF-8'})
    binding.pry
    unless [200, 204].include? response.code
      logger.error('Error status code returned from Crisply API during POST.')
      return false
    end
    true
  end
end
