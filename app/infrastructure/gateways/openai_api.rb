# frozen_string_literal: true

require 'http'
require 'openai'

require_relative 'request'
require_relative 'response'

module TravelRoute
  module OpenAi
    # Api calling the openai api
    class Api
      OPENAI_ENDPOINT = 'https://api.openai.com/v1/chat/completions'

      def initialize(api_key)
        @key = api_key
      end

      def get_time_to_stay(places)
        prompt = <<-PROMPT
        Suggest a time to stay at each place, in hours and what to do.
        Answer in JSON format {"places": ["name": <place_name>, "time": <time_to_spend>, "description": <to_do>]}.
        Places: #{places.join(', ')}
        PROMPT

        Http::Request.post(OPENAI_ENDPOINT, headers, body(prompt)).parse
      end

      def get_recommendation(prompt)
        OpenAiStreamRequest.new(@key, prompt:).call { |block| yield block if block_given? }
      end

      # class for openai request
      class OpenAiStreamRequest
        def initialize(key, prompt:)
          @key = key
          @prompt = prompt
          @client = OpenAI::Client.new(access_token: @key)
        end

        def call
          stream = []
          @client.chat(
            parameters: make_prompt.merge(stream: stream_proc(stream) { |block| yield block if block_given? })
          )
          stream.join
        end

        private

        def make_prompt
          {
            model: 'gpt-3.5-turbo-1106',
            messages: [
              { role: 'system', content: @prompt.system_prompt },
              { role: 'user', content: @prompt.user_prompt }
            ],
            response_format: { type: 'json_object' }
          }
        end

        def stream_proc(stream = [], &block)
          proc do |chunk, _bytesize|
            new_content = chunk.dig('choices', 0, 'delta', 'content')
            stream << new_content unless new_content.nil?
            block.call(stream) if block_given?
          end
        end
      end
    end
  end
end
