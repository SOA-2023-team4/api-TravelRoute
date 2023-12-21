# frozen_string_literal: true

require 'http'

require_relative 'request'
require_relative 'response'

module TravelRoute
  module OpenAi
    # Api calling the openai api
    class Api
      OPENAI_ENDPOINT = 'https://api.openai.com/v1/chat/completions'
      SYSTEM_ROLE_CONTENT = <<-PROMPT
      'You are a traveling expert. You are here to help people plan their trips.'
      PROMPT

      def initialize(api_key)
        @key = api_key
      end

      def get_time_to_stay(places)
        prompt = <<-PROMPT
        Give me a time to stay at each place, in hours. Return in JSON format.
        Places: #{places.join(', ')}
        PROMPT

        Http::Request.post(OPENAI_ENDPOINT, headers, body(prompt)).parse
      end

      def get_recommendation(place, no_of_recommendations = 3, exclude = nil)
        exclude ||= [place.name]
        city = place.city
        prompt = <<-PROMPT
        Recommend #{no_of_recommendations} places to visit for traveling to in #{city}(only in the city) in JSON format {"places": [{"name": <place_name>}]}. I've already went to #{exclude.join(',')}.
        PROMPT
        Http::Request.post(OPENAI_ENDPOINT, headers, body(prompt)).parse
      end

      private

      def headers
        {
          'Content-Type'  => 'application/json',
          'Authorization' => "Bearer #{@key}"
        }
      end

      def body(prompt)
        {
          'model'    => 'gpt-3.5-turbo',
          'messages' => [
            { 'role' => 'system', 'content' => SYSTEM_ROLE_CONTENT },
            { 'role' => 'user', 'content'   => prompt }
          ]
        }
      end
    end
  end
end