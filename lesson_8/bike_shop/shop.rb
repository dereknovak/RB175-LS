require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  @customers = load_all_customer_info
end

def load_all_customer_info
  credentials_path = if ENV["RACK_ENV"] == "test"
    File.expand_path("../test/users.yml", __FILE__)
  else
    File.expand_path("../users.yml", __FILE__)
  end

  YAML.load_file(credentials_path)
end

def load_customer_info(member_number)
  @customers.select do |_, info|
    member_number == info['member_number']
  end
end

def find_customer(params)
  @customers.select do |_, info|
    params[:member_number] == info['member_number'] ||
      params[:first_name].capitalize == info['first_name'] ||
      params[:last_name].capitalize == info['last_name'] ||
      params[:phone_number] == info['phone_number'] ||
      params[:email].downcase == info['email']
  end
end

get '/' do
  redirect '/home'
end

get '/home' do
  erb :home
end

get '/customers/lookup' do
  erb :lookup
end

post '/customers/lookup' do
  customers = load_all_customer_info
  customer = find_customer(params)
  if customer.empty?
    session[:message] = "Customer could not be found."
    status 422
    erb :lookup
  else
    name = customer.keys.first
    redirect "/customers/#{customer[name]['member_number']}"
  end
end

get '/schedule' do
  erb :schedule
end

get '/pricing' do
  erb :pricing
end

get '/customers/:member_number' do
  customer_full = load_customer_info(params[:member_number])
  name = customer_full.keys.first
  @customer = customer_full[name]

  erb :customer
end

get '/workorders/:wo_number' do
  @bicycle = params[:bicycle].split('%20').join(' ')
  erb :workorder
end

=begin

Tasks:
- Create a session for keeping track of work orders
  - Should be tied to customer
  - Session should use a helper method to increment WO nums

- Need to generate a new WO when clicking 'new maintenance'
  - Must carry both the customer and bike information

- On WO, need to add parts/labor and update WO as each gets added
  - Similar to Todo list, adding todos. Use as reference.

=end
