require_relative "test_helper"
require "test/unit"
require 'rack/test'
require_relative '../frontend/main'

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
  def test_PROT_dashboard
    get '/secured/members/home'
    assert last_response.ok?
  end
  def test_PROT_residents
    get '/secured/members/residents'
    assert last_response.ok?
  end
  def test_PROT_docs
    get '/secured/members/docs'
    assert last_response.ok?
  end
  def test_PROT_yom
    get '/secured/members/yom'
    assert last_response.ok?
  end
  def test_PADM_dashboard_static
    get '/admin/dashboard/home'
    assert last_response.ok?
    get '/admin/dashboard/about'
    assert last_response.ok?
  end
  def test_PADM_data
    get '/admin/dashboard/data/yom'
    assert last_response.ok?
    get '/admin/dashboard/data/rd'
    assert last_response.ok?
    get '/admin/dashboard/data/docs'
    assert last_response.ok?
    get '/admin/dashboard/data/news'
    assert last_response.ok?
  end
end
