# frozen_string_literal: true

require 'minitest/autorun'
require 'minitest/rg'
require 'rack/test'
require 'yaml'

require_relative '../app/controllers/app'
require_relative '../app/models/account'

def app
  EtaShare::Api
end

DATA = YAML.safe_load File.read('app/db/seeds/account_seeds.yml')

describe 'Test EtaShare Web API' do
  include Rack::Test::Methods

  before do
    # Wipe database before each test
    Dir.glob("#{EtaShare::STORE_DIR}/*.txt").each { |username| FileUtils.rm(username) }
  end

  it 'should find the root route' do
    get '/'
    _(last_response.status).must_equal 200
  end

  describe 'Handle accounts' do
    it 'HAPPY: should be able to get list of all accounts' do
      EtaShare::Account.new(DATA[0]).save
      EtaShare::Account.new(DATA[1]).save

      get 'api/v1/accounts'
      result = JSON.parse last_response.body
      _(result['account_ids'].count).must_equal 2
    end

    it 'HAPPY: should be able to get details of a single account' do
      EtaShare::Account.new(DATA[1]).save
      id = Dir.glob("#{EtaShare::STORE_DIR}/*.txt").first.split(%r{[/.]})[3]

      get "/api/v1/accounts/#{id}"
      result = JSON.parse last_response.body

      _(last_response.status).must_equal 200
      _(result['id']).must_equal id
    end

    it 'SAD: should return error if unknown account requested' do
      get '/api/v1/accounts/foobar'

      _(last_response.status).must_equal 404
    end

    it 'HAPPY: should be able to create new accounts' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post 'api/v1/accounts', DATA[1].to_json, req_header

      _(last_response.status).must_equal 201
    end
  end
end
