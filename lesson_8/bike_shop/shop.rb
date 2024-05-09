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

  # "#{customer}"

  name = customer.keys.first
  redirect "/customers/#{customer[name]['member_number']}"
end

get '/schedule' do
  erb :schedule
end

get '/pricing' do
  erb :pricing
end

get '/customers/:member_number' do
  customer = load_customer_info(params[:member_number])
  "#{customer}"
end
