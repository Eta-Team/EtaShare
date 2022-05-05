# frozen_string_literal: true

require 'roda'
require_relative './app'

module EtaShare
  # Web controller for EtaShare API
  class Api < Roda
    # rubocop:disable Metrics/BlockLength
    route('links') do |routing|
      @link_route = "#{@api_root}/links"

      routing.on String do |link_id|
        routing.on 'files' do
          @file_route = "#{@api_root}/links/#{link_id}/files"
          # GET api/v1/links/[link_id]/files/[file_id]
          routing.get String do |file_id|
            file = File.where(link_id:, id: file_id).first
            file ? file.to_json : raise('File not found')
          rescue StandardError => e
            routing.halt 404, { message: e.message }.to_json
          end

          # GET api/v1/links/[link_id]/files
          routing.get do
            output = { data: Link.first(id: link_id).files }
            JSON.pretty_generate(output)
          rescue StandardError
            routing.halt(404, { message: 'Could not find files' }.to_json)
          end

          # POST api/v1/links/[link_id]/files
          routing.post do
            new_data = JSON.parse(routing.body.read)

            new_file = CreateFileForLink.call(
              link_id:, file_data: new_data
            )

            response.status = 201
            response['Location'] = "#{@file_route}/#{new_file.id}"
            { message: 'File saved', data: new_file }.to_json
          rescue Sequel::MassAssignmentRestriction
            Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
            routing.halt 400, { message: 'Illegal Attributes' }.to_json
          rescue StandardError => e
            Api.logger.warn "MASS-ASSIGNMENT: #{e.message}"
            routing.halt 500, { message: 'Error creating file' }.to_json
          end
        end

        # GET api/v1/links/[link_id]
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
    # rubocop:enable Metrics/BlockLength
  end
end
