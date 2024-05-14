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

def find_customer(params)
  session[:customers].select do |member_number, info|
    params[:member_number] == member_number.to_s
      params[:first_name].capitalize == info[:first_name] ||
      params[:last_name].capitalize == info[:last_name] ||
      params[:phone_number] == info[:phone_number] ||
      params[:email].downcase == info[:email]
  end
end

def increment_workorders
  session[:workorders].nil? ? 1 :(session[:workorders].keys.max + 1)
end

def increment_member_number
  return 1 unless session[:customers]
  session[:customers].keys.max + 1
end

def increment_bicycle_number(member_number)
  customer = session[:customers][member_number]
  return 1 unless customer[:bicycles]
  customer[:bicycles].keys.max + 1
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

get '/customers/new' do
  erb :new_customer
end

post '/customers/new/add' do
  customer_name = "#{params[:first_name].capitalize} #{params[:last_name].capitalize}"
  member_number = increment_member_number
  if session[:customers]
    session[:customers][member_number] = {
      first_name: customer_name.split.first,
      last_name: customer_name.split.last,
      phone_number: params[:phone_number],
      email: params[:email]
    }
  else
    session[:customers] = { 
      member_number => {
        first_name: customer_name.split.first,
        last_name: customer_name.split.last,
        phone_number: params[:phone_number],
        email: params[:email]
      }
    }
  end

  redirect "/customers/#{member_number}"
end

get '/schedule' do
  erb :schedule
end

get '/pricing' do
  erb :pricing
end

get '/customers/:member_number' do
  @customer = session[:customers][params[:member_number].to_i]
  @name = "#{@customer[:first_name]} #{@customer[:last_name]}"

  # "#{session[:customers][params[:member_number].to_i]}"
  erb :customer
end

get '/customers/:member_number/bicycles/new' do
  erb :new_bicycle
end

post '/customers/:member_number/new/add' do
  @customer = session[:customers][params[:member_number].to_i]
  bicycle_number = increment_bicycle_number(params[:member_number].to_i)

  if @customer[:bicycles]
    @customer[:bicycles][bicycle_number] = {
      serial: params[:serial],
      make: params[:make],
      model: params[:model],
      color: params[:color]
    }
  else
    @customer[:bicycles] = {
      bicycle_number => {
        serial: params[:serial],
        make: params[:make],
        model: params[:model],
        color: params[:color]
      }
    }
  end

  redirect "/customers/#{params[:member_number]}"
end

post '/workorders/:member_number/:bicycle_number/new' do
  @customer = session[:customers][params[:member_number].to_i]
  @bicycle_number = params[:bicycle_number].to_i
  @workorder_number = increment_workorders

  if session[:workorders]
    session[:workorders][@workorder_number] = { customer: @customer, bicycle: @bicycle_number }
  else
    session[:workorders] = { @workorder_number => { customer: @customer, bicycle: @bicycle_number }}
  end

  if @customer[:workorders]
    @customer[:workorders] << @workorder_number
  else
    @customer[:workorders] = [@workorder_number]
  end

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
- Got most of session transition done. Still need some cleanup
    - WO.erb
    - Customer lookup form not working
        - 'find_customer' method?
- Display All WOs on a customer's profile
- Create a new tab for all existing WOs

=end
