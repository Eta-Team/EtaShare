# frozen_string_literal: true

require 'roda'
require 'json'

module EtaShare
  # Web controller for EtaShare API
  class Api < Roda
    plugin :halt

    route do |routing|
      response['Content-Type'] = 'application/json'

      routing.root do
        { message: 'EtaShare up at /api/v1' }.to_json
      end

      @api_root = 'api/v1'
      routing.on @api_root do
        routing.on 'accounts' do
          @account_route = "#{@api_root}/accounts"

          routing.on String do |username|
            # GET api/v1/accounts/[username]
            routing.get do
              account = Account.first(username:)
              account ? account.to_json : raise('Account not found')
            rescue StandardError
              routing.halt 404, { message: error.message }.to_json
            end
          end

          # POST api/v1/accounts
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_account = Account.new(new_data)
            raise('Could not save account') unless new_account.save

            response.status = 201
            response['Location'] = "#{@account_route}/#{new_account.id}"
            { message: 'Account created', data: new_account }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT:: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Request' }.to_json
          rescue StandardError => e
            Api.logger.error 'Unknown error saving account'
            routing.halt 500, { message: e.message }.to_json
          end
        end

        routing.on 'links' do
          @link_route = "#{@api_root}/links"

          routing.on String do |link_id|
            routing.on 'files' do
              @file_route = "#{@api_root}/links/#{link_id}/files"
              # GET api/v1/links/[link_id]/files/[file_id]
              routing.get String do |file_id|
                # SELECT * FROM FILES WHERE `link_id` = `file_id`
                doc = File.where(link_id:, id: file_id).first
                doc ? doc.to_json : raise('File not found')
              rescue StandardError => e
                routing.halt 404, { message: e.message }.to_json
              end

              # GET api/v1/links/[link_id]/files
              routing.get do
                output = { data: Link.first(id: link_id).files }
                JSON.pretty_generate(output)
              rescue StandardError
                routing.halt 404, message: 'Could not find files'
              end

              # POST api/v1/links/[ID]/files
              routing.post do
                new_data = JSON.parse(routing.body.read)
                link = Link.first(id: link_id)
                new_file = link.add_file(new_data)
                raise 'Could not save file' unless new_file

                response.status = 201
                response['Location'] = "#{@file_route}/#{new_file.id}"
                { message: 'File saved', data: new_file }.to_json
              rescue Sequel::MassAssignmentRestriction
                Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
                routing.halt 400, { message: 'Illegal Attributes' }.to_json
              rescue StandardError => e
                routing.halt 500, { message: e.message }.to_json
              end
            end

            # GET api/v1/links/[ID]
            routing.get do
              link = Link.first(id: link_id)
              link ? link.to_json : raise('Link not found')
            rescue StandardError => e
              routing.halt 404, { message: e.message }.to_json
            end
          end

          # GET api/v1/links
          routing.get do
            output = { data: Link.all }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt 404, { message: 'Could not find links' }.to_json
          end

          # POST api/v1/links
          routing.post do
            new_data = JSON.parse(routing.body.read)
            new_link = Link.new(new_data)
            raise('Could not save link') unless new_link.save

            response.status = 201
            response['Location'] = "#{@link_route}/#{new_link.id}"
            { message: 'Link saved', data: new_link }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.error "UNKOWN ERROR: #{e.message}"
            routing.halt 500, { message: 'Unknown server error' }.to_json
          end
        end
      end
    end
  end
end
