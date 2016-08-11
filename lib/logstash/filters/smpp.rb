# encoding: utf-8
require "logstash/filters/base"
require "logstash/namespace"
require 'java'
require 'opensmpp-charset-3.0.0.jar'
require 'opensmpp-core-3.0.0.jar'
require 'faast-common-1.0.0-SNAPSHOT.jar'

java_import "ch.datatrade.faast.common.decoder.PduToMapDecoder"

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
  config :smpp_target, :validate => :string, :default => "smpp"
  config :mnp_target, :validate => :string, :default => "mnp"
  

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
        if smpp_payload[0,1] == '0'
          parsed_values = PduToMapDecoder.decodeSmppHexToMap(smpp_payload)
          target = @smpp_target
        else
          parsed_values = PduToMapDecoder.decodeMnpHexToMap(smpp_payload)
          target = @mnp_target
        end
        unless parsed_values.nil?
          event[target] = {} if event[target].nil?
          parsed_values.each do |key, value|
              event[target][key] = value
          end
        end

      end
      # filter_matched should go in the last line of our successful code
      end
    filter_matched(event)
  end # def filter

end # class LogStash::Filters::Example
