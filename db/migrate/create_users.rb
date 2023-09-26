require "sinatra/activerecord"
require "./config/environment"

ActiveRecord::Migration.create_table :users do |t|
  t.string :username
  t.string :password_digest 
  t.timestamps
end
