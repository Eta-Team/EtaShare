# frozen_string_literal: true

require 'roda'
require 'json'
require_relative './helpers'

module EtaShare
  # Web controller for EtaShare API
  class Api < Roda
    plugin :halt
    plugin :multi_route
    plugin :request_headers

    include SecureRequestHelpers

    def secure_request?(routing)
      routing.scheme.casecmp(Api.config.SECURE_SCHEME).zero?
    end

    route do |routing|
      response['Content-Type'] = 'application/json'

      secure_request?(routing) ||
        routing.halt(403, { message: 'TLS/SSL Required' }.to_json)

      begin
        @auth_account = authenticated_account(routing.headers)
      rescue AuthToken::InvalidTokenError
        routing.halt 403, { message: 'Invalid auth token' }.to_json
      end

      routing.root do
        { message: 'EtaShareAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          @api_root = 'api/v1'
          routing.multi_route
        end
      end
    end
  end
end
