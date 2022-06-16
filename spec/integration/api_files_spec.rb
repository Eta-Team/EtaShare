# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test File Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = EtaShare::Account.create(@account_data)
    @account.add_owned_link(DATA[:links][0])
    @account.add_owned_link(DATA[:links][1])
    EtaShare::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting a single file' do
    it 'HAPPY: should be able to get details of a single file' do
      file_data = DATA[:files][0]
      link = @account.links.first
      file = link.add_file(file_data)

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/files/#{file.id}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['id']).must_equal file.id
      _(result['attributes']['description']).must_equal file_data['description']
      _(result['attributes']['content']).must_equal file_data['content']
    end

    it 'SAD AUTHORIZATION: should not get details without authorization' do
      file_data = DATA[:files][1]
      link = EtaShare::Link.first
      file = link.add_file(file_data)

      get "/api/v1/files/#{file.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'BAD AUTHORIZATION: should not get details with wrong authorization' do
      file_data = DATA[:files][0]
      link = @account.links.first
      file = link.add_file(file_data)

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/files/#{file.id}"

      result = JSON.parse last_response.body

      _(last_response.status).must_equal 403
      _(result['attributes']).must_be_nil
    end

    it 'SAD: should return error if file does not exist' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/files/foobar'

      _(last_response.status).must_equal 404
    end
  end

  describe 'Creating Files' do
    before do
      @link = EtaShare::Link.first
      @file_data = DATA[:files][1]
    end

    it 'HAPPY: should be able to create when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/links/#{@link.identifier}/files", @file_data.to_json
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      file = EtaShare::File.first

      _(created['id']).must_equal file.id
      _(created['description']).must_equal @file_data['description']
      _(created['content']).must_equal @file_data['content']
    end

    it 'BAD AUTHORIZATION: should not create with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      post "api/v1/links/#{@link.identifier}/files", @file_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not create without any authorization' do
      post "api/v1/links/#{@link.identifier}/files", @file_data.to_json

      data = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end

    it 'BAD VULNERABILITY: should not create with mass assignment' do
      bad_data = @file_data.clone
      bad_data['created_at'] = '1900-01-01'
      header 'AUTHORIZATION', auth_header(@account_data)
      post "api/v1/links/#{@link.identifier}/files", bad_data.to_json

      data = JSON.parse(last_response.body)['data']
      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
      _(data).must_be_nil
    end
  end

  describe 'Deleting Files' do
    before do
      @link = EtaShare::Link.first
      @file_data = DATA[:files][1]
      @file = @link.add_file(@file_data)
    end

    it 'HAPPY: should be able to delete when everything correct' do
      header 'AUTHORIZATION', auth_header(@account_data)
      delete "api/v1/links/#{@link.identifier}/files/#{@file.id}"
      _(last_response.status).must_equal 200
    end

    it 'BAD AUTHORIZATION: should not delete with incorrect authorization' do
      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      delete "api/v1/links/#{@link.identifier}/files/#{@file.id}"
      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
    end

    it 'SAD AUTHORIZATION: should not delete without any authorization' do
      delete "api/v1/links/#{@link.identifier}/files/#{@file.id}"

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
    end
  end
end
