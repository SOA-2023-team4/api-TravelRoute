# frozen_string_literal: true

module Background
  # monitor reccommendation process
  class ReccommendationMonitor
    RECCOMMEND_PROCESS = {
      init: { message: 'Looking for attractions...', percent: 10 },
      0 => { message: 'Looking for attractions...', percent: 20 },
      1 => { message: 'Just a moment...', percent: 40 },
      2 => { message: 'Almost there...', percent: 70 },
      3 => { message: 'Almost there...', percent: 90 },
      finished: { message: 'Recommendations are ready! See the map!!', percent: 100 }
    }.freeze

    def self.init_percent
      RECCOMMEND_PROCESS[:init].to_json
    end

    def self.fininsed_percent
      RECCOMMEND_PROCESS[:finished].to_json
    end

    def self.count(stream)
      num_done = StreamParser.new(stream).num_done
      RECCOMMEND_PROCESS[num_done].to_json
    end

    def self.progress(stream)
      StreamParser.new(stream).parse
    end
  end

  # modify the progress stream to be parseable
  class StreamParser
    RECCOMMEND_DONE = /"description": [\s\S]+"[\s\S]+$/
    CONTENT_IN_PLACES = /"places": \[([\s\S]*)(?!\])/
    WHITE_SPACES = /\n\s/
    TRAILING_BLANKETS = /](\s|\S)*/
    PRECEDING_COMMA = /^,[\s\S]+(?={)/

    def initialize(stream)
      @stream = stream.join
    end

    def parse
      extract_stream do |json|
        JSON.parse(json) if json.match?(RECCOMMEND_DONE)
      end&.compact
    rescue JSON::ParserError
      nil
    end

    def num_done
      extract_stream { |json| json.match?(RECCOMMEND_DONE) }&.count(true)
    end

    private

    def extract_stream(&block)
      @stream.gsub(WHITE_SPACES, '').strip.match(CONTENT_IN_PLACES)
        .then { |stm| stm&.captures&.first }
        .then { |stm| stm&.gsub(TRAILING_BLANKETS, '')&.split('}') }
        &.map do |stm|
          complete_json = stm.gsub(PRECEDING_COMMA, '') << '}'
          block.call(complete_json) if block_given?
        end
    end
  end
end
