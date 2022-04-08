# frozen_string_literal: true

require 'roda'
require 'json'

require_relative '../models/account'

module EtaShare
  # Web controller for EtaShare API
  class Api < Roda
    plugin :environments
    plugin :halt

    configure do
      Account.setup
    end

    route do |routing| # rubocop:disable Metrics/BlockLength
      response['Content-Type'] = 'application/json'

      routing.root do
        response.status = 200
        { message: 'EtaShareAPI up at /api/v1' }.to_json
      end

      routing.on 'api' do
        routing.on 'v1' do
          routing.on 'accounts' do
            # GET api/v1/accounts/[id]
            routing.get String do |id|
              response.status = 200
              Account.find(id).to_json
            rescue StandardError
              routing.halt 404, { message: 'Account not found' }.to_json
            end

            # GET api/v1/accounts
            routing.get do
              response.status = 200
              output = { account_ids: Account.all }
              JSON.pretty_generate(output)
            end

            # POST api/v1/accounts
            routing.post do
              new_data = JSON.parse(routing.body.read)
              new_doc = Account.new(new_data)

              if new_doc.save
                response.status = 201
                { message: 'Account saved', id: new_doc.id }.to_json
              else
                routing.halt 400, { message: 'Could not save account' }.to_json
              end
            end
          end
        end
      end
    end
  end
end
