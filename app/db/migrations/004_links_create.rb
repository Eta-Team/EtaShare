# frozen_string_literal: true

require 'sequel'

Sequel.migration do
  change do
    create_table(:links) do
      primary_key :id
      foreign_key :owner_id, :accounts

      String      :title, unique: true, null: false
      String      :description_secure, null: false, default: ''
      String      :is_clicked, null: false, default: '0' # To be converted to Integer '0' -> Not clicked '1' -> Clicked
      String      :valid_period_secure # To be converted to Integer as well -> Will represent the amount of days

      DateTime    :created_at
      DateTime    :updated_at
    end
  end
end
