require "tilt/erubis"
require 'sinatra'
require 'sinatra/reloader'

get "/" do
  redirect "/hello"
  "Hello World"
end

get "/hello" do
  "Hello Hello Hello"
end