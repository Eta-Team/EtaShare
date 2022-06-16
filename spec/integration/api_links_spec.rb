# frozen_string_literal: true

require_relative '../spec_helper'

describe 'Test Link Handling' do
  include Rack::Test::Methods

  before do
    wipe_database

    @account_data = DATA[:accounts][0]
    @wrong_account_data = DATA[:accounts][1]

    @account = EtaShare::Account.create(@account_data)
    @wrong_account = EtaShare::Account.create(@wrong_account_data)

    header 'CONTENT_TYPE', 'application/json'
  end

  describe 'Getting links' do
    describe 'Getting list of all links' do
      before do
        @account.add_owned_link(DATA[:links][0])
        @account.add_owned_link(DATA[:links][1])
      end

      it 'Happy: should get list of authorized accounts' do
        header 'AUTHORIZATION', auth_header(@account_data)
        get 'api/v1/links'
        _(last_response.status).must_equal 200

        result = JSON.parse last_response.body
        _(result['data'].count).must_equal 2
      end

      it 'Bad: should not process for unauthorized account' do
        get 'api/v1/links'
        _(last_response.status).must_equal 403

        result = JSON.parse last_response.body
        _(result['data']).must_be_nil
      end
    end

    it 'HAPPY: should be able to get details of a single link' do
      link = @account.add_owned_link(DATA[:links][0])

      header 'AUTHORIZATION', auth_header(@account_data)
      get "/api/v1/links/#{link.identifier}"
      _(last_response.status).must_equal 200

      result = JSON.parse(last_response.body)['data']
      _(result['attributes']['identifier']).must_equal link.identifier
      _(result['attributes']['title']).must_equal link.title
    end

    it 'SAD: should return error if unknown link requested' do
      header 'AUTHORIZATION', auth_header(@account_data)
      get '/api/v1/links/foobar'

      _(last_response.status).must_equal 404
    end

    it 'BAD AUTHORIZATION: should not get link with wrong authorization' do
      link = @account.add_owned_link(DATA[:links][0])

      header 'AUTHORIZATION', auth_header(@wrong_account_data)
      get "/api/v1/links/#{link.identifier}"
      _(last_response.status).must_equal 403

      result = JSON.parse last_response.body
      _(result['attributes']).must_be_nil
    end

    it 'SECURITY: should prevent basic SQL injection targeting IDs' do
      @account.add_owned_link(DATA[:links][0])
      @account.add_owned_link(DATA[:links][1])

      header 'AUTHORIZATION', auth_header(@account_data)
      get 'api/v1/links/2%20or%20id%3E0'

      # deliberately not reporting error -- don't give attacker information
      _(last_response.status).must_equal 404
      _(last_response.body['data']).must_be_nil
    end
  end

  describe 'Creating New Links' do
    before do
      @link_data = DATA[:links][1]
    end

    it 'HAPPY: should be able to create new links' do
      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/links', @link_data.to_json

      _(last_response.status).must_equal 201
      _(last_response.header['Location'].size).must_be :>, 0

      created = JSON.parse(last_response.body)['data']['attributes']
      link = EtaShare::Link.first

      _(created['identifier']).must_equal link.identifier
      _(created['title']).must_equal @link_data['title']
      _(created['description']).must_equal @link_data['description']
      _(created['valid_period']).must_equal @link_data['valid_period']
      _(created['one_time'].to_i).must_equal @link_data['one_time'].to_i
    end

    it 'SAD: should not create new link without authorization' do
      post 'api/v1/links', @proj_data.to_json

      created = JSON.parse(last_response.body)['data']

      _(last_response.status).must_equal 403
      _(last_response.header['Location']).must_be_nil
      _(created).must_be_nil
    end

    it 'SECURITY: should not create link with mass assignment' do
      bad_data = @link_data.clone
      bad_data['created_at'] = '1900-01-01'

      header 'AUTHORIZATION', auth_header(@account_data)
      post 'api/v1/links', bad_data.to_json

      _(last_response.status).must_equal 400
      _(last_response.header['Location']).must_be_nil
    end
  end
end
