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

      def self.reccommendation_prompt(attraction, num = 3, exclude = nil)
        city = attraction.city
        exclude ||= attraction.name
        prompt = <<-PROMPT
        Recommend #{num} attractions to visit for traveling in #{city}.Excluding #{exclude.join(',')}.
        Answer in JSON format {"places": ["name": <place_name}, "description": <to_do>]}.
        PROMPT
        new(prompt)
      end

      def self.time_to_stay_prompt(attraction)
        prompt = <<-PROMPT
        Suggest a time to stay at each place, in hours and what to do.
        Answer in JSON format {"name": <place_name>, "stay_time": <time_to_spend_int>, "description": <to_do>}.
        Places: #{attraction.name}
        PROMPT
        new(prompt)
      end
    end
  end
end
