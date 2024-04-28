require 'sinatra'
require 'sinatra/reloader'
require 'tilt/erubis'
require 'redcarpet'

root = File.expand_path('..', __FILE__)
markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)

def render_markdown(text)
  markdown = Redcarpet::Markdown.new(Redcarpet::Render::HTML)
  markdown.render(text)
end

def load_file_content(path)
  content = File.read(path)
  
  case File.extname(path)
  when '.txt'
    headers['Content-Type'] = 'text/plain'
    content
  when '.md'
    render_markdown(content)
  end
end

configure do
  enable :sessions
  set :session_secret, SecureRandom.hex(32)
end

before do
  @files = Dir.glob(root + '/data/*').map { |file| File.basename(file) }
end

get '/' do
  erb :index
end

get '/:filename' do
  file_path = root + '/data/' + params[:filename]
  file_name = File.basename(file_path)
  
  if File.exist?(file_path)
    load_file_content(file_path)
  else
    session[:error] = "#{params[:filename]} does not exist."
    redirect '/'
  end
end

post '/:filename' do
  file_path = root + '/data/' + params[:filename]
  file_name = File.basename(file_path)

  File.write(file_path, params[:content])

  session[:message] = "#{file_name} has been updated."
  redirect '/'
end

get '/:filename/edit' do
  file_path = root + '/data/' + params[:filename]
  file_name = File.basename(file_path)

  @filename = params[:filename]
  @content = File.read(file_path)

  erb :edit
end