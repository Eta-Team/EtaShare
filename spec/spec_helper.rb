# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  app.DB[:files].delete
  app.DB[:links].delete
end

DATA = {} # rubocop:disable Style/MutableConstant
DATA[:files] = YAML.safe_load File.read('app/db/seeds/file_seeds.yml')
DATA[:links] = YAML.safe_load File.read('app/db/seeds/link_seeds.yml')
