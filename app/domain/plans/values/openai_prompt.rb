# frozen_string_literal: true

module TravelRoute
  module Value
    # class for handling prompt for openai
    class OpenAiPrompt
      SYSTEM_PROPT = <<-PROMPT
      'You are a traveling expert. You are here to help people plan their trips.'
      PROMPT

      attr_reader :user_prompt, :system_prompt

      def initialize(user_prompt)
        @user_prompt = user_prompt
        @system_prompt = SYSTEM_PROPT
      end

      def self.reccommendation_prompt(attractions, num = 3, exclude = nil)
        city = attractions.first.city
        exclude ||= attractions.map(&:name)
        prompt = <<-PROMPT
        Recommend #{num} places to visit for traveling in #{city}.Excluding #{exclude.join(',')}.
        Answer in JSON format {"places": ["name": <place_name}, "description": <to_do>]}.
        PROMPT
        new(prompt)
      end

      def self.time_to_stay_prompt
        prompt = <<-PROMPT
        Suggest a time to stay at each place, in hours and what to do.
        Answer in JSON format {"places": ["name": <place_name>, "time": <time_to_spend>, "description": <to_do>]}.
        Places: #{@attractions.map(&:name).join(', ')}
        PROMPT
        new(prompt)
      end
    end
  end
end
