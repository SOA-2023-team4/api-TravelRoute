# frozen_string_literal: true

module Background
  # monitor reccommendation process
  class PlannerMonitor
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
  end
end
