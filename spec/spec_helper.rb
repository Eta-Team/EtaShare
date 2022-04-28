# frozen_string_literal: true

ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'minitest/rg'
require 'yaml'

require_relative 'test_load_all'

def wipe_database
  EtaShare::File.map(&:destroy)
  EtaShare::Link.map(&:destroy)
  EtaShare::Account.map(&:destroy)
end

DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seeds.yml')),
  files: YAML.safe_load(File.read('app/db/seeds/files_seeds.yml')),
  links: YAML.safe_load(File.read('app/db/seeds/link_seeds.yml'))
}.freeze
