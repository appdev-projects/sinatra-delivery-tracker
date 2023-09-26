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

class User < ActiveRecord::Base
  has_secure_password
end

# Helper methods to load current user and force sign in
helpers do
  def load_current_user
    the_id = session[:user_id]
    @current_user = User.where({ :id => the_id }).first
  end

  def force_user_sign_in
    if @current_user == nil
      redirect("/user_sign_in")
    end
  end
end

# Do these before any other action in app
before do
  load_current_user

  path_segments = request.path_info.split('/')
  current_path = path_segments[1]
  allowed_paths = ['user_sign_up', 'insert_user', 'user_sign_in']

  if allowed_paths.include?(current_path)
    pass 
  else
    force_user_sign_in
  end
end

# root page
get("/") do
  redirect("/deliveries")
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



get("/users") do
  @list_of_all_users = User.all.order({ :username => :asc })
  erb(:users_index)
end

get("/users/:the_username") do
  the_username = params.fetch("the_username")
  matching_users = User.where({ :username => the_username })
  @the_user = matching_users.at(0)
  erb(:users_show)
end

get("/user_sign_up") do
  erb(:sign_up)
end

post("/insert_user") do
  the_user = User.new
  the_user.username = params.fetch("query_username")
  the_user.password = params.fetch("query_password")
  the_user.save
  session[:user_id] = the_user.id
  redirect("/users/#{the_user.username}")
end

get("/user_sign_in") do
  erb(:sign_in)
end

get("/user_sign_out") do
  session.destroy
  redirect("/")
end

post("/verify_credentials") do
  username = params.fetch("query_username")
  password = params.fetch("query_password")

  # look up the record from the db matching username
  matching_user_records = User.where({ :username => username })
  the_user = matching_user_records.at(0)

  # if there's no record, redirect back to sign in form
  if the_user == nil
    redirect("/user_sign_in")
  else
    # if there is a record, check to see if password matches
    if the_user.authenticate(password)
      session.store(:user_id, the_user.id)

      redirect("/")
    else
      # if not, redirect back to sign in form
      redirect("/user_sign_in")
    end
  end
end

post("/update_user/:the_user_id") do
  the_id = params.fetch("the_user_id")
  matching_users = User.where({ :id => the_id })
  the_user = matching_users.at(0)
  the_user.username = params.fetch("query_username")
  the_user.save
  redirect("/users/#{the_user.username}")
end

get("/delete_user/:the_user_id") do
  username = params.fetch("the_username")
  matching_users = User.where({ :username => username })
  the_user = matching_users.at(0)
  the_user.destroy
  redirect("/users")
end
