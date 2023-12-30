# frozen_string_literal: true

module TravelRoute
  module Value
    # class for handling prompt for openai
    class OpenAiPrompt
      SYSTEM_PROPT = <<-PROMPT
      'You are a traveling expert. You are here to help people plan their trips.'
      PROMPT

      def initialize(attractions, num, exclude = nil)
        @attractions = attractions
        @num = num
        @exclude = exclude
      end

      def reccommendation_prompt
        city = @attractions.first.city
        @exclude ||= @attractions.map(&:name)
        <<-PROMPT
        Recommend #{@num} places to visit for traveling in #{city}.Excluding #{@exclude.join(',')}.
        Answer in JSON format {"places": ["name": <place_name}, "description": <to_do>]}.
        PROMPT
      end

      def time_to_stay_prompt
        <<-PROMPT
        Suggest a time to stay at each place, in hours and what to do.
        Answer in JSON format {"places": ["name": <place_name>, "time": <time_to_spend>, "description": <to_do>]}.
        Places: #{@attractions.map(&:name).join(', ')}
        PROMPT
      end
    end
  end
end
