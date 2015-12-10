# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"

# This filter decode the smpp payload in the specific field and set the fields to event
class LogStash::Filters::Smpp < LogStash::Filters::Base

  # Configuration:
  # [source,ruby]
  # ----------------------------------
  # filter {
  #   smpp {
  #     source => "payload"
  #   }
  # }
  # ----------------------------------
  config_name "smpp"
  
  # Replace the message with this value.
  config :source, :validate => :string, :default => "payload", :required => true
  

  public
  def register
    # Add instance variables 
  end # def register

  public
  def filter(event)

	if @source
		if event.include?(@source)
			# Replace the event message with our message as configured in the
			# config file.
			smpp_payload = event[@source]
			event["test"] = "bla"
		end
		# filter_matched should go in the last line of our successful code
    end
	filter_matched(event)
  end # def filter
end # class LogStash::Filters::Example
