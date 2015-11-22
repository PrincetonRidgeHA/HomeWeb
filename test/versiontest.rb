require_relative "../test_helper"
require "test/unit"
require 'rack/test'
require_relative '../main'

class TestVersion < Test::Unit::TestCase
  include Rack::Test::Methods
  def app
    Sinatra::Application
  end
  def test_homepage
    get '/'
    assert last_response.ok?
  end
  def test_contactpage
    get '/contact'
    assert last_response.ok?
  end
  def test_loginpage
    get '/login'
    assert last_response.ok?
  end
  def test_loginservice
    post '/login', 'inputPassword' => 'test'
  end
end
