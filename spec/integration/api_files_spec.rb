# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test File Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    DATA[:links].each do |link_data|
      EtaShare::Link.create(link_data)
    end
  end

  it 'HAPPY: should be able to get list of all files' do
    link = EtaShare::Link.first
    DATA[:files].each do |file|
      link.add_file(file)
    end

    get "api/v1/links/#{link.id}/files"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data'].count).must_equal 2
  end

  it 'HAPPY: should be able to get details of a single file' do
    file_data = DATA[:files][1]
    link = EtaShare::Link.first
    file = link.add_file(file_data)

    get "/api/v1/links/#{link.id}/files/#{file.id}"
    _(last_response.status).must_equal 200

    result = JSON.parse last_response.body
    _(result['data']['attributes']['id']).must_equal file.id
    _(result['data']['attributes']['name']).must_equal file_data['name']
  end

  it 'SAD: should return error if unknown file requested' do
    link = EtaShare::Link.first
    get "/api/v1/links/#{link.id}/files/foobar"

    _(last_response.status).must_equal 404
  end

  describe 'Creating Files' do
    before do
      @link = EtaShare::Link.first
      @file_data = DATA[:files][1]
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
    end

    it 'HAPPY: should be able to create new files' do
      req_header = { 'CONTENT_TYPE' => 'application/json' }
      post "api/v1/links/#{@link.id}/files",
           @file_data.to_json, req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['data']['attributes']
      file = EtaShare::File.first

      _(created['id']).must_equal file.id
      _(created['name']).must_equal @file_data['name']
      _(created['description']).must_equal @file_data['description']
    end

    it 'SECURITY: should not create files with mass assignment' do
      bad_data = @file_data.clone
      bad_data['created_at'] = '1900-01-01'
      post "api/v1/links/#{@link.id}/files",
           bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
