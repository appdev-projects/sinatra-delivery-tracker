require "sinatra"
require "sinatra/reloader"
require "sinatra/activerecord"

# Define the Delivery model
class Delivery < ActiveRecord::Base
  # Attributes
  # t.integer :user_id
  # t.date :supposed_to_arrive_on
  # t.boolean :arrived
  # t.string :description
  # t.text :details
  # t.timestamps
end

# render a deliveries index
get("/deliveries") do
  @deliveries = Delivery.all
  erb(:deliveries_index)
end

# create a new delivery
post("/insert_delivery") do
  @description = params.fetch("query_description")
  @supposed_to_arrive_on = params.fetch("query_supposed_to_arrive_on")
  @details = params.fetch("query_details")
  

  @delivery = Delivery.new
  @delivery.description = @description
  @delivery.supposed_to_arrive_on = @supposed_to_arrive_on
  @delivery.details = @details
  @delivery.save

  redirect("/deliveries")
end

# show page for a delivery
get("/deliveries/:path_id") do
  @delivery_id = params.fetch("path_id")

  @list_of_deliveries = Delivery.where({ :id => @delivery_id })
  @the_delivery = @list_of_deliveries.first

  erb(:deliveries_show)
end

# edit delivery
get("/modify_delivery/:path_id") do
  @delivery_id = params.fetch("path_id")

  @description = params.fetch("query_description")
  @supposed_to_arrive_on = params.fetch("query_supposed_to_arrive_on")
  @details = params.fetch("query_details")

  @list_of_deliveries = Delivery.where({ :id => @delivery_id })
  @delivery = @list_of_deliveries.first

  @delivery.description = @description
  @delivery.supposed_to_arrive_on = @supposed_to_arrive_on
  @delivery.details = @details
  @delivery.save

  redirect("/deliveries/" + @delivery_id)
end

# delete delivery
get("/delete_delivery/:path_id") do
  @delivery_id = params.fetch("path_id")

  @list_of_deliveries = Delivery.where({ :id => @delivery_id })
  @delivery = @list_of_deliveries.first
  @delivery.destroy

  redirect("/deliveries")
end
