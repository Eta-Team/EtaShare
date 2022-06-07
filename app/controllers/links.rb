# frozen_string_literal: true

require_relative './app'

module EtaShare
  # Links Web controller for EtaShare API
  class Api < Roda
    route('links') do |routing|
      unauthorized_message = { message: 'Unauthorized Request' }.to_json
      routing.halt(403, unauthorized_message) unless @auth_account

      @link_route = "#{@api_root}/links"

      routing.on String do |link_id|
        @req_link = Link.first(identifier: link_id)
        # GET api/v1/links/[ID]
        # binding.pry

        routing.get do
          link = GetLinkQuery.call(
            account: @auth_account, link: @req_link
          )

          { data: link }.to_json
        rescue GetLinkQuery::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue GetLinkQuery::NotFoundError => e
          routing.halt 404, { message: e.message }.to_json
        rescue StandardError => e
          puts "FIND LINK ERROR: #{e.inspect}"
          routing.halt 500, { message: 'API server error' }.to_json
        end

        routing.is do
          routing.put do
            link_data = JSON.parse(routing.body.read)
            # binding.pry
            link = UpdateLinkQuery.call(
              account: @auth_account,
              link: @req_link,
              link_data:
            )
            response.status = 200
            response['Location'] = @link_route + link_id
            { message: 'Link Updated', data: link }.to_json
          end

          routing.delete do
            DeleteLinkQuery.call(
              account: @auth_account,
              link: @req_link
            )
            response.status = 200
            response['Location'] = @link_route
            { message: 'Successfully Deleted' }.to_json
          rescue DeleteLinkQuery::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('files') do
          # POST api/v1/links/[link_id]/files
          @file_route = "#{@api_root}/links/#{link_id}/files"
          routing.post do
            new_file = CreateFile.call(
              account: @auth_account,
              link: @req_link,
              file_data: JSON.parse(routing.body.read)
            )

            response.status = 201
            response['Location'] = "#{@file_route}/#{new_file.id}"
            { message: 'File saved', data: new_file }.to_json
          rescue CreateFile::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue CreateFile::IllegalRequestError => e
            routing.halt 400, { message: e.message }.to_json
          rescue StandardError => e
            Api.logger.warn "Could not create file: #{e.message}"
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end

        routing.on('accessors') do
          # PUT api/v1/links/[link_id]/accessors
          routing.put do
            req_data = JSON.parse(routing.body.read)
            # binding.pry
            accessor = AddAccessor.call(
              account: @auth_account,
              link: @req_link,
              accessor_email: req_data['email']
            )
            { data: accessor }.to_json
          rescue AddAccessor::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end

          # DELETE api/v1/links/[link_id]/accessors
          routing.delete do
            req_data = JSON.parse(routing.body.read)
            accessor = RemoveAccessor.call(
              req_username: @auth_account.username,
              accessor_email: req_data['email'],
              link_id:
            )
            { message: "#{accessor.username} removed from link",
              data: accessor }.to_json
          rescue RemoveAccessor::ForbiddenError => e
            routing.halt 403, { message: e.message }.to_json
          rescue StandardError
            routing.halt 500, { message: 'API server error' }.to_json
          end
        end
      end

      routing.is do
        # GET api/v1/links
        routing.get do
          links = LinkPolicy::AccountScope.new(@auth_account).viewable
          JSON.pretty_generate(data: links)
        rescue StandardError
          routing.halt 403, { message: 'Could not find any links' }.to_json
        end

        # POST api/v1/links
        routing.post do
          new_data = JSON.parse(routing.body.read)
          new_link = @auth_account.add_owned_link(new_data)

          response.status = 201
          response['Location'] = "#{@link_route}/#{new_link.id}"
          { message: 'Link saved', data: new_link }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue StandardError
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
