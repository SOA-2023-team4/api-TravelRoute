# frozen_string_literal: true

require 'vcr'
require 'webmock'

# Setting up VCR
module VcrHelper
  CASSETTES_FOLDER = 'spec/fixtures/cassettes'
  CASSETTE_FILE = 'gmaps_api'

  def self.setup_vcr
    VCR.configure do |c|
      c.cassette_library_dir = CASSETTES_FOLDER
      c.hook_into :webmock
      c.ignore_hosts 'sqs.ap-southeast-2.amazonaws.com'
    end
  end

  def self.configure_vcr_for_gmap
    VCR.configure do |c|
      c.filter_sensitive_data('<GMAP_TOKEN>') { GMAP_TOKEN }
      c.filter_sensitive_data('<GMAP_TOKEN_ESC>') { CGI.escape(GMAP_TOKEN) }
    end

    VCR.insert_cassette(
      CASSETTE_FILE,
      record: :new_episodes,
      match_requests_on: %i[method uri headers body]
    )
  end

  def self.eject_vcr
    VCR.eject_cassette
  end
end
