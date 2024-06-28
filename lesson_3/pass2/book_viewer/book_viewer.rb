require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"
require "pry"

helpers do
  def in_paragraphs(text)
    text.split("\n\n").map.with_index do |line, idx|
      "<p id=paragraph#{idx}>#{line}</p>"
    end.join
  end

  def highlight(text, query)
    text.gsub(query, "<strong>#{query}</strong>")
  end
end

def each_chapter
  @contents.each_with_index do |name, idx|
    number = idx + 1
    contents = File.read("data/chp#{number}.txt").split("\n\n")
    yield number, name, contents
  end
end

def chapters_matching(query)
  results = []

  return results if !query || query.empty?

  each_chapter do |number, name, contents|
    found_text = contents.map.with_index {|content, idx| [content, idx] }
    found_text.select! { |content, _| content.include?(query) }
    results << {number: number, name: name, paragraphs: found_text} unless found_text.empty?
  end

  results
end

before do
  @contents = File.readlines('data/toc.txt')
end

not_found do
  redirect '/'
end

get "/" do
  @tab = "Table of Contents"
  @title = "The Adventures of Sherlock Holmes"

  erb :home
end

get "/chapters/:number" do
  number = params[:number].to_i

  redirect '/' unless (1..@contents.size).cover? number

  @tab = "Chapter #{number}"
  @title = "Chapter #{number} - #{@contents[number - 1]}"
  @chapter = File.read("data/chp#{params[:number]}.txt")

  erb :chapter
end

get "/search" do
  @results = chapters_matching(params[:query])
  erb :search
end
