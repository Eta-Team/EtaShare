# frozen_string_literal: true

require_relative './app'

module EtaShare
  # Links Web controller for EtaShare API
  class Api < Roda
    route('links') do |routing|
      routing.halt(403, UNAUTH_MSG) unless @auth_account

      @link_route = "#{@api_root}/links"

      routing.on String do |link_id|
        @req_link = Link.first(identifier: link_id)

        # GET api/v1/links/[ID]
        routing.get do
          link = GetLinkQuery.call(
            auth: @auth, link: @req_link
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
              auth: @auth,
              link: @req_link,
              link_data:
            )
            response.status = 200
            response['Location'] = @link_route + link_id
            { message: 'Link Updated', data: link }.to_json
          end

          routing.delete do
            DeleteLinkQuery.call(
              auth: @auth,
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
          routing.is do
            @file_route = "#{@api_root}/links/#{link_id}/files"
            routing.post do
              new_file = CreateFile.call(
                auth: @auth,
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

          routing.on(String) do |file_id|
            routing.delete do
              file = File.first(id: file_id)
              DeleteFileQuery.call(
                auth: @auth,
                link: @req_link,
                file:
              )
              response.status = 200
              response['Location'] = @link_route
              { message: 'Successfully Deleted' }.to_json
            rescue DeleteFileQuery::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end
        end

        routing.on('forfeit') do
          routing.is do
            routing.delete do
              ForfeitAccessQuery.call(
                auth: @auth,
                link: @req_link
              )
              response.status = 200
              response['Location'] = @link_route
              { message: 'Successfully Forfeited Access' }.to_json
            rescue ForfeitAccessQuery::ForbiddenError => e
              routing.halt 403, { message: e.message }.to_json
            rescue StandardError
              routing.halt 500, { message: 'API server error' }.to_json
            end
          end
        end

        routing.on('accessors') do
          # PUT api/v1/links/[link_id]/accessors
          routing.put do
            req_data = JSON.parse(routing.body.read)
            # binding.pry
            accessor = AddAccessor.call(
              auth: @auth,
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
              auth: @auth,
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
          new_link = CreateLinkForOwner.call(
            auth: @auth, link_data: new_data
          )
          # new_link = @auth_account.add_owned_link(new_data)
          response.status = 201
          response['Location'] = "#{@link_route}/#{new_link.id}"
          { message: 'Link saved', data: new_link }.to_json
        rescue Sequel::MassAssignmentRestriction
          Api.logger.warn "MASS-ASSIGNMENT: #{new_data.keys}"
          routing.halt 400, { message: 'Illegal Request' }.to_json
        rescue CreateLinkForOwner::ForbiddenError => e
          routing.halt 403, { message: e.message }.to_json
        rescue StandardError => e
          Api.logger.error "Unknown error: #{e.message}"
          routing.halt 500, { message: 'API server error' }.to_json
        end
      end
    end
  end
end
