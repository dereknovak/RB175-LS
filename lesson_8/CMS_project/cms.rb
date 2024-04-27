require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'

root = File.expand_path('..', __FILE__)

before do
  @files = Dir.glob(root + '/data/*').map { |file| File.basename(file) }
end

get '/' do
  erb :index
end

get '/:file' do
  file_path = root + '/data/' + params[:file]

  headers['Content-Type'] = 'text/plain'
  File.read(file_path)
end