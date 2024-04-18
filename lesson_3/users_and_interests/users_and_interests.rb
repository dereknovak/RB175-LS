require 'tilt/erubis'
require 'sinatra'
require 'sinatra/reloader'
require 'yaml'

get '/' do
  @users = Psych.load_file('users.yaml').keys.join("\n")
end

get '/:name' do
  
end