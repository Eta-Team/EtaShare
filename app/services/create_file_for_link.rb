# frozen_string_literal: true

module EtaShare
  # Create new configuration for a link
  class CreateFileForLink
    def self.call(link_id:, file_data:)
      Link.first(id: link_id)
          .add_file(file_data)
    end
  end
end
