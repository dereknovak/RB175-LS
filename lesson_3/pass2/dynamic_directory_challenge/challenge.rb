require 'sinatra'
require 'sinatra/reloader'

helpers do
  def ascending_sort?
    @files == @files.sort
  end
end

get '/' do
  @files = Dir.glob('public/*').map { |file| File.basename(file) }.sort
  @files.reverse! if params[:sort] == 'desc'

  erb :home
end