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

def increment_workorders
  session[:workorders].nil? ? 1 :(session[:workorders].keys.max + 1)
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

post '/workorders/:member_number/:bicycle/new' do
  @customer = load_customer_info(params[:member_number])
  @bicycle = params[:bicycle]
  @workorder_number = increment_workorders

  session[:workorders] = { @workorder_number => { customer: @customer, bicycle: @bicycle }}

  @customer['workorders'] = @workorder_number
  redirect "/workorders/#{@workorder_number}"
end

get '/workorders/:workorder_number' do
  @customer = session[:workorders][params[:workorder_number].to_i][:customer].values.first
  @bicycle = session[:workorders][params[:workorder_number].to_i][:bicycle]

  erb :workorder
end

post '/workorders/:workorder_number/add' do
  @customer = session[:workorders][params[:workorder_number].to_i][:customer].values.first
  @bicycle = session[:workorders][params[:workorder_number].to_i][:bicycle]

  if params[:labor]
    if @customer['bicycles'][@bicycle][:labor]
      @customer['bicycles'][@bicycle][:labor] << params[:labor]
    else
      @customer['bicycles'][@bicycle][:labor] = [params[:labor]]
    end
  elsif params[:part_name]
    if @customer['bicycles'][@bicycle][:parts]
      @customer['bicycles'][@bicycle][:parts] << params[:part_name]
    else
      @customer['bicycles'][@bicycle][:parts] = [params[:part_name]]
    end
  end
  
  # "#{@customer['bicycles'][@bicycle][:labor]}"
  redirect "/workorders/#{params[:workorder_number]}"
end

=begin

Tasks:
- USE TODO LIST AS EXAMPLE

- New WOs are overwriting old ones. Fix.
- Display All WOs on a customer's profile
- Create a new tab for all existing WOs

=end
