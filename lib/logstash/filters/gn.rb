# encoding: utf-8
require "logstash/filters/base"
require "json"
require "logstash/namespace"
require 'faraday'


# This  filter will replace the contents of the default
# message field with whatever you specify in the configuration.
#
# It is only intended to be used as an .
class LogStash::Filters::Gn < LogStash::Filters::Base

  # Setting the config_name here is required. This is how you
  # configure this filter from your Logstash config.
  #
  # filter {
  #    {
  #     message => "My message..."
  #   }
  # }
  #
  config_name "gn"

  # Replace the message with this value.
  config :ip, :validate => :string, :required => true, :default => "61.163.128.58"
  config :key, :validate => :string, :required => false



  public
  def register
  end # def register

  public
  def filter(event)

    if @key
      url = "https://enterprise.api.greynoise.io/v2/noise/context/" + event.get('ip')
      uri = URI.parse(URI.encode(url.strip))

      response = Faraday.get(uri, nil, Key: event.get('apikey'))
    else
      url = "https://api.greynoise.io/v1/query/ip"
      response = Faraday.post url, { :ip => event.get('ip') }

    end

    result = JSON.parse(response.body)

    event.set('greynoise', result)
    # filter_matched should go in the last line of our successful code
    filter_matched(event)

  end # def filter
end # class LogStash::Filters::Gn
