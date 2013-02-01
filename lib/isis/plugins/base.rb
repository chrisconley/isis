require 'httparty'
# Plugin base class

module Isis
  module Plugin
    class Base
      def respond_to_msg?(msg, speaker)
        /\b[!]?isepta\b/i =~ msg
      end
      def receive_message(msg, speaker, room = nil)
        if respond_to_msg?(msg, speaker)
          @room = room
          msg = msg.downcase
          msg = msg.gsub(/\!isepta/, '')
          from, to = msg.split(' to ').map{|s| s.strip.upcase}
          response = HTTParty.get("http://isepta-api-v2.herokuapp.com/trains.json?to=#{to}&from=#{from}&day=wk")

          if response.to_a.size > 0
            departures = response.map do |train|
              train["departs_at"].gsub(/:00$/, '')
            end
            times = departures[0..2].join(', ')
            "Departing at: #{times}"
          else
            'Whoops! Couldn\'t find trains for "msg"'
          end
        end
      end
    end
  end
end
