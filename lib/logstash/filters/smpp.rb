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
        event[target] = {} if event[target].nil?
        parsed_values.each do |key, value|
          #if key != "dlr"
            event[target][key] = value
          #else
            #delivery_data_key = "dlr";
            #data_map = split_delivery_data(value)
            #event[target][delivery_data_key] = {}
            #data_map.each do |del_key, del_value|
            #  event[target][delivery_data_key][del_key] = del_value
            #end
          #end
        end

      end
      # filter_matched should go in the last line of our successful code
      end
    filter_matched(event)
  end # def filter

  def split_delivery_data(data)
    data_map = {}
    data_parts = data.split(':')
    key = ''
    value = ''
    counter = 1
    data_parts.each {
      |data_part|
      if counter == 1
        key = data_part
        counter += 1
      else
        if 'text' == key
          data_map[key] = data_part
        else
          parts = data_part.split(' ')
          value = parts.first
          data_map[key] = value
          key = parts[1..-1].join('_')
        end
      end
    }
    data_map
  end
end # class LogStash::Filters::Example
