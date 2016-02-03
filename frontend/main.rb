#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'slim'
require 'rest-client'
require 'json'
require 'csv'
require 'tilt/redcarpet'
require 'sinatra/activerecord'
require 'rack-flash'
require 'newrelic_rpm'
require_relative '../config/environments'
require_relative 'inc/notifications'
require_relative 'models/residents.rb'
require_relative 'models/docs.rb'
require_relative 'models/yard_winners.rb'
require_relative 'models/news.rb'
require_relative 'models/contacts.rb'
require_relative 'inc/pagevars'
require_relative 'inc/mailer'
require_relative 'inc/dateservice'
require_relative 'inc/viewdata'
require_relative 'inc/pagination'

set :port, ENV['PORT'] || 8080
set :bind, ENV['IP'] || '0.0.0.0'


enable :sessions
use Rack::Flash

helpers do
  ##
  # Defines if current user is logged in
  def login?
    if ENV['CI']
      return true
    elsif session[:authusr].nil?
      return false
    else
      return true
    end
  end
  ##
  # Defines if current user is logged in through OAuth GitHub gateway
  def adminlogin?
    if ENV['CI']
      return true
    elsif session[:adminauth].nil?
      return false
    else
      return true
    end
  end
end
##
# Route handler for home page
get '/' do
  # Transfer all locals to instance variables
  @view_data = ViewData.new('bootstrap_v3', 'Home', flash[:notice])
  @view_data.add_css_url('/src/css/home.css')
  # Retrieve Yard of the Month data
  current_winner = Yardwinners.all.order(month: :desc).limit(1).first
  @view_data.set_var('yom_winner', current_winner)
  # Use generic image if none exists
  if(@view_data.get_var('yom_winner').imgpath == '#')
    img_temp = @view_data.get_var('yom_winner')
    img_temp.imgpath = "data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="
    @view_data.set_var('yom_winner', img_temp)
  end
  slim :home
end
##
# Route handler for contact page
get '/contact' do
  @view_data = ViewData.new('bootstrap_v3', "Contact", flash[:notice])
  slim :bugreport
end
##
# Route handler for POST to contact page
#
# Sends data to Mailer class
post '/contact' do
  Mailer.send(Pagevars.set_vars("ADMINMAIL"), "AUTO: PRHA bug report", params[:msgbody])
  redirect '/'
end
##
# Route handler for login page
get '/login' do
  @view_data = ViewData.new('bootstrap_v3', 'Login', flash[:notice])
  @view_data.add_css_url('/src/css/login.css')
  if(session[:authtries].nil?)
    session[:authtries] = 0
    slim :login
  elsif(session[:authtries] <= 3)
    slim :login
  else
    @errdetail = '0x1'
    slim :error
  end
end
##
# Authenticicates user and sets up session keys
post '/login' do
  if(params[:inputPassword] == ENV['ADMIN_PWD'])
    session[:authusr] = true
    redirect '/secured/members/home'
  else
    if(session[:authtries].nil?)
      session[:authtries] = 1
      redirect '/login'
    elsif(session[:authtries] <= 3)
      session[:authtries] = session[:authtries] + 1
      redirect '/login'
    else
      @errdetail = '0x1'
      slim :error
    end
  end
end
##
# Route handler for specific news article
get '/news/:id' do
  article = News.find(params[:id])
  @view_data = ViewData.new('bootstrap_v3', article.title + ' - News', flash[:notice])
  @view_data.add_css_url('/src/css/home.css')
  @view_data.set_var('article', article)
  slim :news_article
end
##
# Route handler for news feed page
get '/news' do
  articles = News.all.order(uploaddate: :desc)
  @view_data = ViewData.new('bootstrap_v3', 'News', flash[:notice])
  @view_data.add_css_url('/src/css/home.css')
  @view_data.set_var('articles', articles)
  slim :news
end
##
# Route handler for resetting login block (RACK_ENV:TEST only!)
get '/test/:key/resetauth' do
  if(params[:key] == 'PRHAKEY')
    session[:authtries] = 0
    redirect '/'
  else
    redirect '/'
  end
end
##
# Route handler for home page of members dashboard
get '/secured/members/home' do
  redirect '/login' unless login?
  @view_data = ViewData.new('bootstrap_v3', 'Members Dashboard', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  slim :member_home
end
##
# Route handler for resident directory of members dashboard
get '/secured/members/residents' do
  redirect '/login' unless login?
  @view_data = ViewData.new('bootstrap_v3', 'Resident Directory', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @view_data.add_js_url('/src/js/member/disclaimer.js')
  @view_data.add_js_url('//cdnjs.cloudflare.com/ajax/libs/bootbox.js/4.4.0/bootbox.min.js')
  @pagination = Pagination.new(Residents.count, params['pg'])
  @view_data.set_var('items', Residents.all.order(:name).limit(10).offset(@pagination.get_start_index))
  slim :member_directory
end
##
# Route handler for documents list of members dashboard
get '/secured/members/docs' do
  redirect '/login' unless login?
  @view_data = ViewData.new('bootstrap_v3', 'Documents', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @pagination = Pagination.new(Docs.count, params['pg'])
  @items = Docs.all.order(uploaddate: :desc).limit(10).offset(@pagination.get_start_index)
  slim :member_docs
end
##
# Route handler for YOM winners of members dashboard
get '/secured/members/yom' do
  redirect '/login' unless login?
  @view_data = ViewData.new('bootstrap_v3', 'Yard of the Month', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @pagination = Pagination.new(Yardwinners.count, params['pg'])
  @items = Yardwinners.all.order(:id).limit(10).offset(@pagination.get_start_index)
  slim :member_yom
end
##
# Route handler for contacts page of members dashboard
get '/secured/members/contacts' do
  redirect '/login' unless login?
  @view_data = ViewData.new('bootstrap_v3', 'Contacts', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @items = Contacts.all.order(:id)
  slim :member_contacts
end
##
# Route handler for admin login
get '/admin/login' do
  @view_data = ViewData.new('metro_v3', 'Administrator Login', flash[:notice])
  @view_data.add_css_url('/src/css/admin/login.css')
  @gitid = ENV['GITHUB_CLIENT_ID']
  slim :admin_login
end
##
# Route handler for OAuth logins
#
# Normally only called by GitHub API after '/admin/login' redirect
get '/admin/oauth/v2/github/callback' do
  # get temporary GitHub code...
  session_code = request.env['rack.request.query_hash']['code']

  # ... and POST it back to GitHub
  result = RestClient.post('https://github.com/login/oauth/access_token',
                          {:client_id => ENV['GITHUB_CLIENT_ID'],
                           :client_secret => ENV['GITHUB_CLIENT_SECRET'],
                           :code => session_code},
                           :accept => :json)

  # extract the token and granted scopes
  access_token = JSON.parse(result)['access_token']
  auth_result = JSON.parse(RestClient.get('https://api.github.com/user',
                                        {:params => {:access_token => access_token}}))
  session[:adminauth] = true
  session[:adminkey] = access_token
  session[:admin_username] = auth_result['login']
  session[:admin_profilepic] = auth_result['avatar_url']
  flash[:notice] = "Welcome back " + session[:admin_username]
  redirect '/admin/dashboard/home'
end
##
##
# Route handler for admin dashboard home
get '/admin/dashboard/home' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'Dashboard', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  slim :admin_dashboard
end
##
# Route handler for admin dashboard YOM data view
get '/admin/dashboard/data/yom' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'Dashboard', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  @contactscount = Contacts.count
  # Page specific data
  @items = Yardwinners.all.order(:id)
  slim :admin_data_yom
end
##
# Route handler for POST to admin dashboard YOM data view
post '/admin/dashboard/data/yom' do
  redirect '/admin/login' unless adminlogin?
  # Perform operation with data
  if(params['operation'] == 'Update')
    opdata = Yardwinners.find(params['yardwinnerdata']['id'])
    opdata.name = params['yardwinnerdata']['name']
    opdata.address = params['yardwinnerdata']['address']
    opdata.month = params['yardwinnerdata']['month']
    opdata.year = params['yardwinnerdata']['year']
    opdata.imgpath = params['yardwinnerdata']['imgpath']
    begin
      opdata.save
      flash[:notify] = 'Record updated.'
    rescue
      flash[:notify] = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params[:yardwinnerdata]['id'] = Yardwinners.count
      yomwinner = Yardwinners.new(params[:yardwinnerdata])
      yomwinner.save
      flash[:notify] = 'Record added.'
    rescue
      flash[:notify] = 'Record add failed!'
    end
  elsif(params['operation'] == 'Delete')
    begin
      opdata = Yardwinners.find(params['yardwinnerdata']['id'])
      opdata.delete
      flash[:notify] = 'Record deleted.'
    rescue
      flash[:notify] = 'Record delete failed!'
    end
  end
  redirect 'admin/dashboard/data/yom'
end
##
# Route handler for admin dashboard resident directory data view
get '/admin/dashboard/data/rd' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'Residents', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  @contactscount = Contacts.count
  # Page specific data
  @items = Residents.all.order(:name)
  slim :admin_data_rd
end
##
# Route handler for POST to admin dashboard resident directory data view
post '/admin/dashboard/data/rd' do
  redirect '/admin/login' unless adminlogin?
  #perform operation with data
  if(params['operation'] == 'Update')
    opdata = Residents.find(params['rdd']['id'])
    opdata.name = params['rdd']['name']
    opdata.addr = params['rdd']['addr']
    opdata.email = params['rdd']['email']
    opdata.pnum = params['rdd']['pnum']
    begin
      opdata.save
      flash[:notify] = 'Record updated.'
    rescue
      flash[:notify] = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    params['rdd']['id'] = Residents.count
    begin
      red = Residents.new(params['rdd'])
      red.save
      flash[:notify] = 'Record added.'
    rescue
      flash[:notify] = 'Record add failed!'
    end
  elsif(params['operation'] == 'Delete')
    begin
      opdata = Residents.find(params['rdd']['id'])
      opdata.delete
      flash[:notify] = 'Record deleted.'
    rescue
      flash[:notify] = 'Record delete failed!'
    end
  end
  redirect '/admin/dashboard/data/rd'
end
##
# Route handler for admin dashboard document list data view
get '/admin/dashboard/data/docs' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'Documents', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  @contactscount = Contacts.count
  # Page specific data
  @items = Docs.all
  slim :admin_data_docs
end
##
# Route handler for POST to admin dashboard document list data view
post '/admin/dashboard/data/docs' do
  redirect '/admin/login' unless adminlogin?
  #perform operation with data
  if(params['operation'] == 'Update')
    opdata = Docs.find(params['doc']['id'])
    opdata.name = params['doc']['name']
    opdata.uploaddate = params['doc']['uploaddate']
    opdata.uploadedby = params['doc']['uploadedby']
    opdata.url = params['doc']['url']
    begin
      opdata.save
      flash[:notify] = 'Record updated.'
    rescue
      flash[:notify] = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    params['doc']['id'] = Docs.count
    begin
      docdata = Docs.new(params['doc'])
      docdata.save
      flash[:notify] = 'Record added.'
    rescue
      flash[:notify] = 'Record add failed!'
    end
  elsif(params['operation'] == 'Delete')
    begin
      opdata = Docs.find(params['doc']['id'])
      opdata.delete
      flash[:notify] = 'Record deleted.'
    rescue
      flash[:notify] = 'Record delete failed!'
    end
  end
  redirect '/admin/dashboard/data/docs'
end
##
# Route handler for admin dashboard news listing data view
get '/admin/dashboard/data/news' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'News', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  @contactscount = Contacts.count
  # Page specific data
  @items = News.all.order(:id)
  slim :admin_data_news
end
##
# Route handler for POST to admin dashboard news listing data view
post '/admin/dashboard/data/news' do
  redirect '/admin/login' unless adminlogin?
  #perform operation with data
  if(params['operation'] == 'Update')
    opdata = News.find(params['newsdata']['id'])
    opdata.title = params['newsdata']['title']
    opdata.content = params['newsdata']['content']
    opdata.uploaddate = params['newsdata']['uploaddate']
    opdata.uploadedby = params['newsdata']['uploadedby']
    begin
      opdata.save
      flash[:notify] = 'Record updated.'
    rescue
      flash[:notify] = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params['newsdata']['id'] = News.count
      newsobj = News.new(params['newsdata'])
      newsobj.save
      flash[:notify] = 'Record added.'
    rescue
      flash[:notify] = 'Record add failed!'
    end
  elsif(params['operation'] == 'Delete')
    begin
      opdata = News.find(params['newsdata']['id'])
      opdata.delete
      flash[:notify] = 'Record deleted.'
    rescue
      flash[:notify] = 'Record delete failed!'
    end
  end
  redirect '/admin/dashboard/data/news'
end
##
# Route handler for admin dashboard contacts data view
get '/admin/dashboard/data/contacts' do
  redirect '/admin/login' unless adminlogin?
  @view_data = ViewData.new('metro_v3', 'Contacts', flash[:notice])
  @view_data.add_css_url('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  @contactscount = Contacts.count
  # Page specific data
  @items = Contacts.all.order(:id)
  slim :admin_data_contacts
end
##
# Route handler for POST to admin dashboard contacts data view
post '/admin/dashboard/data/contacts' do
  redirect '/admin/login' unless adminlogin?
  #perform operation with data
  if(params['operation'] == 'Update')
    opdata = Contacts.find(params['condata']['id'])
    opdata.title = params['condata']['title']
    opdata.name = params['condata']['name']
    opdata.email = params['condata']['email']
    begin
      opdata.save
      flash[:notify] = 'Record updated.'
    rescue
      flash[:notify] = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params['condata']['id'] = News.count
      newsobj = Contacts.new(params['condata'])
	    newsobj.save
	    flash[:notify] = 'Record added.'
    rescue
      flash[:notify] = 'Record add failed!'
    end
  elsif(params['operation'] == 'Delete')
    begin
      opdata = Contacts.find(params['condata']['id'])
      opdata.delete
      flash[:notify] = 'Record deleted.'
    rescue
      flash[:notify] = 'Record delete failed!'
    end
  end
  redirect '/admin/dashboard/data/contacts'
end
##
# Route handler for CSV file output of allowed data structures
get '/raw/protected/residents.csv' do
  redirect '/login' unless login?
  response.headers['content_type'] = "application/octet-stream"
  attachment('residents.csv')
  item = Residents.all.order(:name)
  response.write(item.as_csv)
end