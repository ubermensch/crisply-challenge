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
    p_r = ActivityItem.new(:text => "Push made to #{payload[:repository][:name]} GitHub repo",
                           :guid => ActivityItem.generate_guid)
  end

  def self.generate_guid
    "post-activity-#{Time.now.to_i}-#{rand(100)}"
  end

  def to_crisply!
    #xml_payload = self.to_xml(:skip_instruct => true, :only => [:text, :guid])
    xml_payload = "<?xml version='1.0' encoding='UTF-8'?><activity-item xmlns='http://crisply.com/api/v1'><guid>#{guid}</guid><text>#{text}</text></activity-item>"

    # add the xmlns= declaration to the top of the payload, this is required by the API.
    #xml_payload["<activity-item>"] = '<activity-item xmlns="http://crisply.com/api/v1">'

    response = HTTParty.post('https://frankhmeidan.crisply.com/timesheet/api/activity_items.xml',
                  :body => xml_payload,
                  :format => :xml,
                  :basic_auth => {:username => 'jrt1O6bumuGw2K04hD0J', :password => 'jrt1O6bumuGw2K04hD0J'},
                  :headers => {'Content-Type' => 'application/xml',
                               'Accept' => 'application/xml',
                               'X-Crisply-Authentication' => 'jrt1O6bumuGw2K04hD0J'})
    binding.pry
    #unless [200, 204].include? response.code
    #  logger.error('Error status code returned from Crisply API during POST.')
    #  return false
    #end
    #true
  end

end
