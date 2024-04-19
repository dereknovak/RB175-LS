require 'tilt/erubis'
require 'sinatra'
require 'sinatra/reloader'
require 'yaml'

before do
  @users = Psych.load_file('users.yaml')
end

helpers do
  def count_interests(users)
    users.reduce(0) do |sum, (name, user)|
      sum + user[:interests].size
    end
  end
end

get '/' do
  erb :home
end

get '/:name' do |name|
  @name = name
  @info = Psych.load_file('users.yaml')[name.to_sym]
  @email = @info[:email]
  @interests = @info[:interests]
  @others = @users.keys.select { |user| user.to_s != name }

  erb :info
end