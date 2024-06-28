require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'yaml'

before do
  @messages = YAML.load_file('users.yaml')
end

get '/' do
  "#{@messages}"
end