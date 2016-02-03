require_relative "test_helper"
require "test/unit"
require 'rack/test'
require_relative '../frontend/main'

class TestVersion < Test::Unit::TestCase
  include Rack::Test::Methods
  self.test_order = :defined
  
  # Initialize testing objects
  def app
    Sinatra::Application
  end
  # Test static pages
  def test_homepage
    get '/'
    assert last_response.ok?
  end
  def test_contactpage
    get '/contact'
    assert last_response.ok?
  end
  def test_news
    # Set up sample data
    test_data = Hash.new
    test_data['title'] = 'News Title'
    test_data['content'] = 'Content goes here'
    test_data['uploaddate'] = '20160101'
    test_data['uploadedby'] = 'Travis CI Test Service'
    # Test create method
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Create'}
    get '/news'
    assert last_response.ok?
    # Test delete method
    test_data['id'] = 0
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  def test_news_item
    # Set up sample data
    test_data = Hash.new
    test_data['title'] = 'News Title'
    test_data['content'] = 'Content goes here'
    test_data['uploaddate'] = '20160101'
    test_data['uploadedby'] = 'Travis CI Test Service'
    # Test create method
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Create'}
    get '/news/0'
    assert last_response.ok?
    # Test delete method
    test_data['id'] = 0
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  # Test login system
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
  # Test members area
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
  # Test administration panel
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
  def test_padm_data_contacts
    get '/admin/dashboard/data/contacts'
    assert last_response.ok?
  end
  # Test underlying database structure
  def test_padm_data_yom_manip
    # Set up sample data
    test_data = Hash.new
    test_data['name'] = 'Sample Name'
    test_data['address'] = '123 Sample street'
    test_data['month'] = 1
    test_data['year'] = 2000
    test_data['imgpath'] = '#'
    # Test create method
    post "/admin/dashboard/data/yom", {:yardwinnerdata => test_data, :operation => 'Create'}
    assert last_response.redirect?
    # Update data
    test_data['id'] = 0
    test_data['address'] = '321 Sample street'
    # Test update method
    post "/admin/dashboard/data/yom", {:yardwinnerdata => test_data, :operation => 'Update'}
    assert last_response.redirect?
    # Test delete method
    post "/admin/dashboard/data/yom", {:yardwinnerdata => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  def test_padm_data_rd_manip
    # Set up sample data
    test_data = Hash.new
    test_data['name'] = 'Sample Name'
    test_data['addr'] = '123 Sample street'
    test_data['email'] = 'user@example.com'
    test_data['pnum'] = '1111111111'
    # Test create method
    post "/admin/dashboard/data/rd", {:rdd => test_data, :operation => 'Create'}
    assert last_response.redirect?
    # Update data
    test_data['id'] = 0
    test_data['pnum'] = '2222222222'
    # Test update method
    post "/admin/dashboard/data/rd", {:rdd => test_data, :operation => 'Update'}
    assert last_response.redirect?
    # Test delete method
    post "/admin/dashboard/data/rd", {:rdd => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  def test_padm_data_docs_manip
    # Set up sample data
    test_data = Hash.new
    test_data['name'] = 'Sample Document'
    test_data['uploaddate'] = '20160101'
    test_data['uploadedby'] = 'Travis CI'
    test_data['url'] = 'http://127.0.0.1'
    # Test create method
    post "/admin/dashboard/data/docs", {:doc => test_data, :operation => 'Create'}
    assert last_response.redirect?
    # Update data
    test_data['id'] = 0
    test_data['name'] = 'New Sample Document'
    # Test update method
    post "/admin/dashboard/data/docs", {:doc => test_data, :operation => 'Update'}
    assert last_response.redirect?
    # Test delete method
    post "/admin/dashboard/data/docs", {:doc => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  def test_padm_data_news_manip
    # Set up sample data
    test_data = Hash.new
    test_data['title'] = 'News Title'
    test_data['content'] = 'Content goes here'
    test_data['uploaddate'] = '20160101'
    test_data['uploadedby'] = 'Travis CI Test Service'
    # Test create method
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Create'}
    assert last_response.redirect?
    # Update data
    test_data['id'] = 0
    test_data['title'] = 'News Update'
    # Test update method
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Update'}
    assert last_response.redirect?
    # Test delete method
    post "/admin/dashboard/data/news", {:newsdata => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  def test_padm_data_contacts_manip
    # Set up sample data
    test_data = Hash.new
    test_data['title'] = 'Supreme Leader'
    test_data['name'] = 'Travis CI'
    test_data['email'] = 'user@example.com'
    # Test create method
    post "/admin/dashboard/data/contacts", {:condata => test_data, :operation => 'Create'}
    assert last_response.redirect?
    # Update data
    test_data['id'] = 0
    test_data['title'] = 'Dictator-For-Life'
    # Test update method
    post "/admin/dashboard/data/contacts", {:condata => test_data, :operation => 'Update'}
    assert last_response.redirect?
    # Test delete method
    post "/admin/dashboard/data/contacts", {:condata => test_data, :operation => 'Delete'}
    assert last_response.redirect?
  end
  # Test raw file endpoints
  def test_raw_residents
    get '/raw/protected/residents.csv'
    assert last_response.ok?
  end
end
