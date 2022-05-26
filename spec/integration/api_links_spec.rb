# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  include Rack::Test::Methods

  before do
    wipe_database
  end

  describe 'Getting links' do
    describe 'Getting list of all links' do
      before do
        @account_data = DATA[:accounts][0]
        account = EtaShare::Account.create(@account_data)
        account.add_owned_link(DATA[:links][0])
        account.add_owned_link(DATA[:links][1])
      end

      it 'Happy: should get list of authorized accounts' do
        auth = EtaShare::AuthenticateAccount.call(
          username: @account['username'],
          password: @account['password']
        )

        header 'AUTHORIZATTION', "Bearer #{auth[:attributes][:auth_token]}"
        get 'api/v1/links'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'Bad: should not process for unauthorized account' do
        header 'AUTHORIZATION', 'Bearer bad_token'
        get 'api/v1/links'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single link' do
      existing_link = DATA[:links][1]
      EtaShare::Link.create(existing_link)
      id = EtaShare::Link.first.id

      get "/api/v1/links/#{id}"
      _(last_response.status).must_equal 200

      result = JSON.parse last_response.body
      _(result['attributes']['id']).must_equal id
      _(result['attributes']['title']).must_equal existing_link['title']
    end

    it 'SAD: should return error if unknown link requested' do
      get '/api/v1/links/foobar'

      _(last_response.status).must_equal 404
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      EtaShare::Link.create(title: 'New Link')
      EtaShare::Link.create(title: 'Newer Link')
      get 'api/v1/links/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Links' do
    before do
      @req_header = { 'CONTENT_TYPE' => 'application/json' }
      @link_data = DATA[:links][1]
    end

    it 'HAPPY: should be able to create new links' do
      post 'api/v1/links', @link_data.to_json, @req_header
      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      link = EtaShare::Link.first

      _(created['id']).must_equal link.id
      _(created['title']).must_equal @link_data['title']
      _(created['description']).must_equal @link_data['description']
      _(created['is_clicked']).must_equal @link_data['is_clicked']
      _(created['valid_period']).must_equal @link_data['valid_period']
    end

    it 'SECURITY: should not create link with mass assignment' do
      bad_data = @link_data.clone
      bad_data['created_at'] = '1900-01-01'
      post 'api/v1/links', bad_data.to_json, @req_header

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
