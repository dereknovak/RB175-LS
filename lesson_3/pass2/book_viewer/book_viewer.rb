require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  @title = "The Adventures of Sherlock Holmes"
  @contents = File.readlines('data/toc.txt')

  erb :home
end

get "/chapters/:chapter_number" do
  @title = "Chapter #{params[:chapter_number]}"
  @contents = File.readlines('data/toc.txt')
  @chapter = File.read("data/chp#{params[:chapter_number]}.txt")

  erb :chapter
end
