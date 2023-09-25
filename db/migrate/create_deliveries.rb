require "sinatra/activerecord"
require "./config/environment"

ActiveRecord::Migration.create_table :deliveries do |t|
  t.integer :user_id
  t.date :supposed_to_arrive_on
  t.boolean :arrived
  t.string :description
  t.text :details

  t.timestamps
end
