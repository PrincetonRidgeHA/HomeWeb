#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'slim'
require 'rest-client'
require 'json'
require 'sinatra/activerecord'
require './config/environments'
require './inc/notifications'
require './models/residents.rb'
require './models/docs.rb'
require './models/yard_winners.rb'
require_relative 'inc/pagevars'
require_relative 'inc/mailer'
require_relative 'inc/dateservice'

set :port, ENV['PORT'] || 8080
set :bind, ENV['IP'] || '0.0.0.0'

enable :sessions

helpers do
  def partial(template, locals = {})
    slim template, :layout => false, :locals => locals
  end
  def login?
    if session[:authusr].nil?
      return false
    else
      return true
    end
  end
  def adminlogin?
    if session[:adminauth].nil?
      return false
    else
      return true
    end
  end
end

get '/' do
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Home"
  @notif = Notifications.get_all()
  @bcolor = "#5a5a5a"
  @cssimport = Array.new
  @cssimport.push('/src/css/home.css')
  @style = 'bootstrap'
  yom_max_year = 1990
  yom_max_month = 0
  @yom_image = "http://princetonridge.com/Entry.JPG"
  # @yom_name = "Error"
  # @yom_addr_short = "Error"
  # @yom_month = "Error"
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
  if(@yom_image == '#')
    @yom_image = "data:image/gif;base64,R0lGODlhAQABAIAAAHd3dwAAACH5BAAAAAAALAAAAAABAAEAAAICRAEAOw=="
  end
  slim :home
end
get '/contact' do
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  slim :bugreport
end
post '/contact' do
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  slim :processing
  Mailer.send(Pagevars.set_vars("ADMINMAIL"), "AUTO: PRHA bug report", params[:msgbody])
  redirect '/'
end
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
    if(session[:authtries] == nil)
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
get '/test/:key/resetauth' do
  if(params[:key] == 'PRHAKEY')
    session[:authtries] = 0
    redirect '/'
  else
    redirect '/'
  end
end
get '/test/:key/dbinsert/resident' do
  redirect '/login' unless login?
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:key] == 'PRHAKEY')
    slim :test_dbinsert_resident
  else
    @errdetail = '0x3'
    slim :error
  end
end
post '/test/:key/dbinsert/resident' do
  redirect '/login' unless login?
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:key] == 'PRHAKEY')
    idct = 0;
    while(true)
      params[:residents]['id'] = idct;
      if(idct >= 1000)
        @errdetail = '0x2'
        slim :error
        break
      end
      begin
        @residents = Residents.new(params[:residents])
	      @residents.save
	      break
      rescue
        idct = idct + 1;
      end
    end
    slim :test_dbinsert_resident
  else
    @errdetail = '0x3'
    slim :error
  end
end
get '/secured/members/:page' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:page] == 'home')
    @PageTitle = "Home - Residents Dashboard"
    slim :member_home
  elsif(params[:page] == 'residents')
    @PageTitle = "Directory - Residents Dashboard"
    @items = Residents.all.order(:name)
    slim :member_directory
  elsif(params[:page] == 'docs')
    @PageTitle = "Documents - Residents Dashboard"
    @items = Docs.all.order(:id)
    slim :member_docs
  elsif(params[:page] == 'yom')
    @PageTitle = "Yard of the Month - Residents Dashboard"
    @items = Yardwinners.all.order(:id)
    slim :member_yom
  else
    redirect '/secured/members/home'
  end
end
get '/admin/login' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Administrator Sign In"
  @cssimport = Array.new
  @cssimport.push '/src/css/admin/login.css'
  @style = 'metro'
  slim :admin_login
end
post '/admin/login' do
  # client = Octokit::Client.new(:login => params['user_login'], :password => params['user_password'])
  # Fetch the current user
  # client.user
  session[:adminauth] = true
  session[:admin_username] = params['user_login']
  session[:admin_secret] = params['user_password']
  redirect '/admin/dashboard'
end
get '/admin/dashboard' do
  redirect '/admin/dashboard/home'
end
get '/admin/dashboard/home' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Administration"
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  @style = 'metro'
  slim :admin_dashboard
end
get '/admin/dashboard/about' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "About"
  @cssimport = Array.new
  @cssimport.push('/src/css/admin/dashboard.css')
  @admin_uname = session[:admin_username]
  @style = 'metro'
  slim :admin_dashboard_about
end
get '/admin/dashboard/data/yom' do
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
  # Page specific data
  @items = Yardwinners.all.order(:id)
  slim :admin_data_yom
end
post '/admin/dashboard/data/yom' do
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
  # Page specific data
  @items = Yardwinners.all.order(:id)
  slim :admin_data_yom
end
get '/admin/dashboard/data/rd' do
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
  # Page specific data
  @items = Residents.all.order(:name)
  slim :admin_data_rd
end
post '/admin/dashboard/data/rd' do
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
    idct = 0;
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
  # Page specific data
  @items = Residents.all.order(:name)
  slim :admin_data_rd
end
get '/admin/dashboard/data/docs' do
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
  # Page specific data
  @items = Docs.all
  slim :admin_data_docs
end
post '/admin/dashboard/data/docs' do
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
  # Page specific data
  @items = Docs.all
  slim :admin_data_docs
end