# frozen_string_literal: true

require_relative './app'

module EtaShare
  # File Web controller for Credence API
  class Api < Roda
    route('files') do |routing|
      routing.halt 403, { message: 'Not authorized' }.to_json unless @auth_account

      @file_route = "#{@api_root}/files"

      # GET api/v1/files/[file_id]
      routing.on String do |file_id|
        @req_file = File.first(id: file_id)

        routing.get do
          file = GetFileQuery.call(
            auth: @auth, file: @req_file
          )

          { data: file }.to_json
        rescue GetFileQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetFileQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.warn "File Error: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
