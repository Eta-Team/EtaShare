# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:files) do
      primary_key   :id
      foreign_key   :link_id, table: :links

      String        :name, null: false
      String        :description, null: false, default: ''

      DateTime      :created_at
      DateTime      :updated_at

      unique %i[link_id name]
    end
  end
end
