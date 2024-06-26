ENV['RACK_ENV'] = 'test'

require 'minitest/autorun'
require 'rack/test'
require 'fileutils'

require_relative '../cms'

class CMSTest < Minitest::Test
  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    FileUtils.mkdir_p(data_path)
  end

  def teardown
    FileUtils.rm_rf(data_path)
  end

  def create_document(name, content = '')
    File.open(File.join(data_path, name), 'w') do |file|
      file.write(content)
    end
  end

  def test_index
    create_document 'about.md'
    create_document 'changes.txt'

    get '/'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, 'about.md'
    assert_includes last_response.body, 'changes.txt'
  end

  def test_viewing_text_document
    create_document 'history.txt', 'Testing content'

    get '/history.txt'

    assert_equal 200, last_response.status
    assert_equal 'text/plain', last_response['Content-Type']
    assert_includes last_response.body, "Testing content"
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
    create_document 'about.md', '# Testing heading'

    get '/about.md'

    assert_equal 200, last_response.status
    assert_equal 'text/html;charset=utf-8', last_response['Content-Type']
    assert_includes last_response.body, '<h1>Testing heading</h1>'
  end

  def test_edit_page
    create_document 'test.txt', 'Testing content'

    get '/test.txt/edit'
    assert_equal 200, last_response.status
    assert_includes last_response.body, '<textarea'
    assert_includes last_response.body, %q(<button type='submit')
  end

  def test_updating_document
    create_document 'test.txt', 'Test number 1'

    get '/test.txt'
    assert_equal 'Test number 1', last_response.body
    
    post '/test.txt', content: 'Test number 2'
    assert_equal 302, last_response.status

    get '/test.txt'
    assert_equal 200, last_response.status
    assert_equal 'Test number 2', last_response.body
  end
end