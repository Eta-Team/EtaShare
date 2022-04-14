# frozen_string_literal: true

require_relative './spec_helper'

describe 'Test Links' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  it 'HAPPY: should be able to get list of all links' do
    EtaShare::Link.create(DATA[:links][0]).save
    EtaShare::Link.create(DATA[:links][1]).save

    get 'api/v1/links'
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single link' do
    existing_link = DATA[:links][1]
    EtaShare::Link.create(existing_link).save
    id = EtaShare::Link.first.id

    get "/api/v1/links/#{id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal id
    _(result['data']['attributes']['title']).must_equal existing_link['title']
  end

  it 'SAD: should return error if unknown link requested' do
    get '/api/v1/links/foobar'

    _(last_response.status).must_equal 404
  end

  it 'HAPPY: should be able to create new links' do
    existing_link = DATA[:links][1]

    req_header = { 'CONTENT_TYPE' => 'application/json' }
    post 'api/v1/links', existing_link.to_json, req_header
    _(last_response.status).must_equal 201
    _(last_response.header['Location'].size).must_be :>, 0

    created = JSON.parse(last_response.body)['data']['data']['attributes']
    link = EtaShare::Link.first

    _(created['id']).must_equal link.id
    _(created['title']).must_equal existing_link['title']
    _(created['description']).must_equal existing_link['description']
    # _(created['is_clicked']).must_equal existing_link['is_clicked']
    # _(created['valid_period']).must_equal existing_link['valid_period']
  end
end
