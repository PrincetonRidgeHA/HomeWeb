#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'slim'
require 'rest-client'
require 'json'
require 'csv'
require 'tilt/redcarpet'
require 'sinatra/activerecord'
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

set :port, ENV['PORT'] || 8080
set :bind, ENV['IP'] || '0.0.0.0'


enable :sessions

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
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Home"
  @notif = Notifications.get_all()
  @bcolor = "#5a5a5a"
  @cssimport = Array.new
  @cssimport.push('/src/css/home.css')
  @style = 'bootstrap'
  # Retrieve Yard of the Month data
  yom_max_year = 1990
  yom_max_month = 0
  @yom_image = "http://princetonridge.com/Entry.JPG"
  Yardwinners.all.each do |item|
    if(item.year > yom_max_year)
      yom_max_year = item.year
      yom_max_month = item.month
      @yom_image = item.imgpath
      @yom_name = item.name
      @yom_addr_short = item.address
      @yom_month = Dateservice.get_month(item.month)
    elsif(item.year == yom_max_year)
      if(item.month > yom_max_month)
        yom_max_year = item.year
        yom_max_month = item.month
        @yom_image = item.imgpath
        @yom_name = item.name
        @yom_addr_short = item.address
        @yom_month = Dateservice.get_month(item.month)
      end
    end
  end
  # Use generic image if none exists
  if(@yom_image == '#')
    @yom_image = "data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="
  end
  slim :home
end
##
# Route handler for contact page
get '/contact' do
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  slim :bugreport
end
##
# Route handler for POST to contact page
#
# Sends data to Mailer class
post '/contact' do
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  slim :processing
  Mailer.send(Pagevars.set_vars("ADMINMAIL"), "AUTO: PRHA bug report", params[:msgbody])
  redirect '/'
end
##
# Route handler for login page
get '/login' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Sign in"
  @cssimport = Array.new
  @style = 'bootstrap'
  if(session[:authtries] == nil)
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
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Sign in"
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:inputPassword] == ENV['ADMIN_PWD'])
    session[:authusr] = true
    redirect '/secured/members/home'
  else
    @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
    @PageTitle = "Sign in"
    if(session[:authtries].nil?)
      session[:authtries] = 1
      slim :login
    elsif(session[:authtries] <= 3)
      session[:authtries] = session[:authtries] + 1
      slim :login
    else
      @errdetail = '0x1'
      slim :error
    end
  end
end
##
# Route handler for specific news article
get '/news/:id' do
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @bcolor = "#5a5a5a"
  @cssimport = Array.new
  @cssimport.push('/src/css/home.css')
  @style = 'bootstrap'
  @article = News.find(params[:id])
  @PageTitle = "#{@article.title} - News"
  slim :news_article
end
##
# Route handler for news feed page
get '/news' do
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @PageTitle = "News"
  @bcolor = "#5a5a5a"
  @cssimport = Array.new
  @cssimport.push('/src/css/home.css')
  @style = 'bootstrap'
  @articles = News.all.order(uploaddate: :desc)
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
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/dashboard.css'
  @style = 'bootstrap'
  @PageTitle = "Home - Residents Dashboard"
  slim :member_home
end
##
# Route handler for resident directory of members dashboard
get '/secured/members/residents' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/dashboard.css'
  @style = 'bootstrap'
  @PageTitle = "Directory - Residents Dashboard"
  # Calculate pagination parameters
  start_index = 0
  @current_page = 0
  if(!params['pg'])
    start_index = 0
    @current_page = 1
  else
    start_index = params['pg'].to_i * 10
    @current_page = params['pg'].to_i
    start_index -= 10
    if(start_index > Residents.count)
      redirect '/secured/members/residents'
    end
  end
  @items = Residents.all.order(:name).limit(10).offset(start_index)
  @num_pages = Residents.count / 10
  if(Residents.count % 10 > 0)
    @num_pages += 1
  end
  slim :member_directory
end
##
# Route handler for documents list of members dashboard
get '/secured/members/docs' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/dashboard.css'
  @style = 'bootstrap'
  @PageTitle = "Documents - Residents Dashboard"
  # Calculate pagination parameters
  start_index = 0
  if(!params['pg'])
    start_index = 0
    @current_page = 1
  else
    start_index = params['pg'].to_i * 10
    @current_page = params['pg'].to_i
    start_index -= 10
    if(start_index > Docs.count)
      redirect '/secured/members/docs'
    end
  end
  @items = Docs.all.order(uploaddate: :desc).limit(10).offset(start_index)
  @num_pages = Docs.count / 10
  if(Docs.count % 10 > 0)
    @num_pages += 1
  end
  slim :member_docs
end
##
# Route handler for YOM winners of members dashboard
get '/secured/members/yom' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/dashboard.css'
  @style = 'bootstrap'
  @PageTitle = "Yard of the Month - Residents Dashboard"
  # Calculate pagination parameters
  start_index = 0
  if(!params['pg'])
    start_index = 0
    @current_page = 1
  else
    start_index = params['pg'].to_i * 10
    @current_page = params['pg'].to_i
    start_index -= 10
    if(start_index > Yardwinners.count)
      redirect '/secured/members/yom'
    end
  end
  @items = Yardwinners.all.order(:id).limit(10).offset(start_index)
  @num_pages = Yardwinners.count / 10
  if(Yardwinners.count % 10 > 0)
    @num_pages += 1
  end
  slim :member_yom
end
##
# Route handler for contacts page of members dashboard
get '/secured/members/contacts' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/dashboard.css'
  @style = 'bootstrap'
  @PageTitle = "Contacts - Residents Dashboard"
  @items = Contacts.all.order(:id)
  slim :member_contacts
end
##
# Redirects user to login page, or dashboard if logged in
get '/admin' do
  redirect '/admin/login' unless adminlogin?
  redirect '/admin/dashboard'
end
##
# Route handler for admin login
get '/admin/login' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Administrator Sign In"
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/login.css'
  @style = 'metro'
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
  redirect '/admin/dashboard'
end
##
# Redirects to admin dashboard home
get '/admin/dashboard' do
  redirect '/admin/login' unless adminlogin?
  redirect '/admin/dashboard/home'
end
##
# Route handler for admin dashboard home
get '/admin/dashboard/home' do
  redirect '/admin/login' unless adminlogin?
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Administration"
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  @style = 'metro'
  slim :admin_dashboard
end
##
# Route handler for admin dashboard YOM data view
get '/admin/dashboard/data/yom' do
  redirect '/admin/login' unless adminlogin?
  # Global page parameters
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Yard of the Month"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  # Page specific data
  @items = Yardwinners.all.order(:id)
  slim :admin_data_yom
end
##
# Route handler for POST to admin dashboard YOM data view
post '/admin/dashboard/data/yom' do
  redirect '/admin/login' unless adminlogin?
  #perform operation with data
  if(params['operation'] == 'Update')
    opdata = Yardwinners.find(params['yardwinnerdata']['id'])
    opdata.name = params['yardwinnerdata']['name']
    opdata.address = params['yardwinnerdata']['address']
    opdata.month = params['yardwinnerdata']['month']
    opdata.year = params['yardwinnerdata']['year']
    opdata.imgpath = params['yardwinnerdata']['imgpath']
    begin
      opdata.save
      transmessage = 'Record updated.'
    rescue
      transmessage = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params[:yardwinnerdata]['id'] = Yardwinners.count
      yomwinner = Yardwinners.new(params[:yardwinnerdata])
	    yomwinner.save
	    transmessage = 'Record added.'
    rescue
      transmessage = 'Record add failed!'
    end
  end
  # Global page parameters
  @notif = Notifications.get_all()
  @notif.push(transmessage)
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Yard of the Month"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  # Page specific data
  @items = Yardwinners.all.order(:id)
  slim :admin_data_yom
end
##
# Route handler for admin dashboard resident directory data view
get '/admin/dashboard/data/rd' do
  redirect '/admin/login' unless adminlogin?
  # Global page parameters
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Residents"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
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
      transmessage = 'Record updated.'
    rescue
      transmessage = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    params['rdd']['id'] = Residents.count
    begin
      red = Residents.new(params['rdd'])
      red.save
      transmessage = 'Record added.'
    rescue
      transmessage = 'Record add failed!'
    end
  end
  # Global page parameters
  @notif = Notifications.get_all()
  @notif.push(transmessage)
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Residents"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  # Page specific data
  @items = Residents.all.order(:name)
  slim :admin_data_rd
end
##
# Route handler for admin dashboard document list data view
get '/admin/dashboard/data/docs' do
  redirect '/admin/login' unless adminlogin?
  # Global page parameters
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Documents"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
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
      transmessage = 'Record updated.'
    rescue
      transmessage = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    params['doc']['id'] = Docs.count
    begin
      docdata = Docs.new(params['doc'])
      docdata.save
      transmessage = 'Record added.'
    rescue
      transmessage = 'Record add failed!'
    end
  end
  # Global page parameters
  @notif = Notifications.get_all()
  @notif.push(transmessage)
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Documents"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  # Page specific data
  @items = Docs.all
  slim :admin_data_docs
end
##
# Route handler for admin dashboard news listing data view
get '/admin/dashboard/data/news' do
  redirect '/admin/login' unless adminlogin?
  # Global page parameters
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "News"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
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
      transmessage = 'Record updated.'
    rescue
      transmessage = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params['newsdata']['id'] = News.count
      newsobj = News.new(params['newsdata'])
	    newsobj.save
	    transmessage = 'Record added.'
    rescue
      transmessage = 'Record add failed!'
    end
  end
  # Global page parameters
  @notif = Notifications.get_all()
  @notif.push(transmessage)
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "News"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
  @admin_uname = session[:admin_username]
  # Data page information
  @yomcount = Yardwinners.count
  @rdcount = Residents.count
  @docscount = Docs.count
  @newscount = News.count
  # Page specific data
  @items = News.all.order(:id)
  slim :admin_data_news
end
##
# Route handler for admin dashboard contacts data view
get '/admin/dashboard/data/contacts' do
  redirect '/admin/login' unless adminlogin?
  # Global page parameters
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Contacts"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
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
      transmessage = 'Record updated.'
    rescue
      transmessage = 'Record update failed!'
    end
  elsif(params['operation'] == 'Create')
    begin
      params['condata']['id'] = News.count
      newsobj = Contacts.new(params['condata'])
	    newsobj.save
	    transmessage = 'Record added.'
    rescue
      transmessage = 'Record add failed!'
    end
  end
  # Global page parameters
  @notif = Notifications.get_all()
  @notif.push(transmessage)
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Contacts"
  # Styling
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @style = 'metro'
  # Admin dashboard parameters
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
# Route handler for CSV file output of allowed data structures
get '/raw/protected/:item.csv' do
  redirect '/login' unless login?
  response.headers['content_type'] = "application/octet-stream"
  attachment(params[:item] + '.csv')
  if(params[:item] == 'residents')
    item = Residents.all.order(:name)
  end
  response.write(item.as_csv)
end