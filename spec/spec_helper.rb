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

def authenticate(account_data)
  EtaShare::AuthenticateAccount.call(
    username: account_data['username'],
    password: account_data['password']
  )
end

def auth_header(account_data)
  auth = authenticate(account_data)

  "Bearer #{auth[:attributes][:auth_token]}"
end

def authorization(account_data)
  auth = authenticate(account_data)

  token = AuthToken.new(auth[:attributes][:auth_token])
  account = token.payload['attributes']
  { account: EtaShare::Account.first(username: account['username']),
    scope: AuthScope.new(token.scope) }
end

DATA = {
  accounts: YAML.safe_load(File.read('app/db/seeds/accounts_seed.yml')),
  files: YAML.safe_load(File.read('app/db/seeds/files_seed.yml')),
  links: YAML.safe_load(File.read('app/db/seeds/links_seed.yml'))
}.freeze
