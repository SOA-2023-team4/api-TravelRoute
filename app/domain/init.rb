# frozen_string_literal: true

folders = %w[plans]
folders.each do |folder|
  require_relative "#{folder}/init"
end
