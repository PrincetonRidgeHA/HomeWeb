require_relative "test_helper"
require "test/unit"
require 'rack/test'
require_relative '../frontend/main'

class TestVersion < Test::Unit::TestCase
  include Rack::Test::Methods
  self.test_order = :defined
  
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
  def test_news
    get '/news'
    assert last_response.ok?
  end
  def test_news_item
    get '/news/0'
    assert last_response.ok?
  end
  def test_login_reset
    get '/test/BADKEY/resetauth'
    assert last_response.redirect?
    get '/test/PRHAKEY/resetauth'
    assert last_response.redirect?
  end
  def test_loginpage
    get '/login'
    assert last_response.ok?
  end
  def test_loginservice
    post '/login', 'inputPassword' => ENV['ADMIN_PWD']
    assert last_response.redirect?
  end
  def test_prot_dashboard
    get '/secured/members/home'
    assert last_response.ok?
  end
  def test_prot_residents
    get '/secured/members/residents'
    assert last_response.ok?
  end
  def test_prot_docs
    get '/secured/members/docs'
    assert last_response.ok?
  end
  def test_prot_yom
    get '/secured/members/yom'
    assert last_response.ok?
  end
  def test_prot_contacts
    get '/secured/members/contacts'
    assert last_response.ok?
  end
  def test_padm_dashboard_static
    get '/admin/dashboard/home'
    assert last_response.ok?
  end
  def test_padm_data_yom
    get '/admin/dashboard/data/yom'
    assert last_response.ok?
  end
  def test_padm_data_rd
    get '/admin/dashboard/data/rd'
    assert last_response.ok?
  end
  def test_padm_data_docs
    get '/admin/dashboard/data/docs'
    assert last_response.ok?
  end
  def test_padm_data_news
    get '/admin/dashboard/data/news'
    assert last_response.ok?
  end
  def test_raw_residents
    get '/raw/protected/residents.csv'
    assert last_response.ok?
  end
end
