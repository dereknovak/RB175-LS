ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_index
    get '/'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.md'
    assert_includes last_response.body, 'changes.txt'
    assert_includes last_response.body, 'history.txt'
  end

  def test_viewing_text_document
    get '/history.txt'

    history_body = <<~TXT.chomp
    1993 - Yukihiro Matsumoto dreams up Ruby.
    1995 - Ruby 0.95 released.
    1996 - Ruby 1.0 released.
    1998 - Ruby 1.2 released.
    1999 - Ruby 1.4 released.
    2000 - Ruby 1.6 released.
    2003 - Ruby 1.8 released.
    2007 - Ruby 1.9 released.
    2013 - Ruby 2.0 released.
    2013 - Ruby 2.1 released.
    2014 - Ruby 2.2 released.
    2015 - Ruby 2.3 released.
    2016 - Ruby 2.4 released.
    2017 - Ruby 2.5 released.
    2018 - Ruby 2.6 released.
    2019 - Ruby 2.7 released.
    2020 - Ruby 3.0 released.
    2021 - Ruby 3.1 released.
    2022 - Ruby 3.2 released.
    TXT

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_equal history_body, last_response.body
  end

  def test_file_does_not_exist
    get '/notafile.txt'
    assert_equal 302, last_response.status

    get last_response['Location']
    assert_equal 200, last_response.status
    assert_includes last_response.body, 'notafile.txt does not exist.'
    
    get '/'
    refute_includes last_response.body, 'notafile.txt does not exist.'
  end

  def test_view_markdown_file
    get '/about.md'
    assert_equal 200, last_response.status
    assert_equal 'text/html', last_response['Content-Type']
    assert_includes last_response.body, 'Ruby is'
  end
end