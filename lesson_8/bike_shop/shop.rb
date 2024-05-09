require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  session[:customers] ||= []
end

# def load_customer_info
#   credentials_path = if ENV["RACK_ENV"] == "test"
#     File.expand_path("../test/users.yml", __FILE__)
#   else
#     File.expand_path("../users.yml", __FILE__)
#   end

#   YAML.load_file(credentials_path)
# end

def find_customer(first_name, last_name, phone_number, email)
  customer = session[:customers].find do |_, info|
    first_name.capitalize == info['first_name'] ||
      last_name.capitalize == info['last_name'] ||
      phone_number == info['phone_number'] ||
      email == info['email']
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
  customers = load_customer_info

  customer = find_customer(params[:first_name], params[:last_name],
                           params[:phone_number], params[:email])

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
  find_customer(
end

# Move YAML over to sessions for now. In the future
# I will most likely be using MySQL