class ActivityItem < ActiveRecord::Base
  attr_accessible :text, :guid, :type
  validates :text, :guid, :presence => true

  CRISPLY_API = {
    :base => 'https://frankhmeidan.crisply.com/timesheet/api',
    :token => 'jrt1O6bumuGw2K04hD0J'
  }

  # Creates and saves a new ProxiedRequest object from the given
  # github webhook JSON payload
  def self.from_github(payload)
    puts "payload is: #{payload}"
    text = "Push made to #{payload[:repository][:name]} GitHub repo"
    if payload[:commits].present? and payload[:commits].size > 0 and payload[:commits][0][:message].present?
      text += " - commit message: '#{payload[:commits][0][:message]}'"
    end

    p_r = ActivityItem.create(:text => text,
                              :guid => ActivityItem.generate_guid)
  end

  def self.generate_guid
    "post-activity-#{Time.now.to_i}-#{rand(100)}"
  end

  def to_crisply!
    xml_payload = "<activity-item xmlns='http://crisply.com/api/v1'><guid>#{guid}</guid><text>#{text}</text></activity-item>"
    response = HTTParty.post("#{CRISPLY_API[:base]}/activity_items.xml",
                  :body => xml_payload,
                  :format => :xml,
                  :basic_auth => {:username => CRISPLY_API[:token], :password => ''},
                  :headers => {'Content-Type' => 'application/xml; charset=UTF-8'})
    if response.code != 201
      logger.error "Could not POST activity item to Crisply API - status code returned was #{response.code}"
    else
      self.sent_to_crisply = true
      save
    end
  end

end
