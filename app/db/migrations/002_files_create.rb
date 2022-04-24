# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:files) do
      uuid          :id, primary_key: true
      foreign_key   :link_id, table: :links

      String        :name, null: false
      String        :description_secure, null: false, default: ''

      DateTime      :created_at
      DateTime      :updated_at

      unique %i[link_id name]
    end
  end
end
