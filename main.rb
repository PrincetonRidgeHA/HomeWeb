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
get '/test/:key/dbinsert/yom' do
  redirect '/login' unless login?
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:key] == 'PRHAKEY')
    slim :test_dbinsert_yom
  else
    @errdetail = '0x3'
    slim :error
  end
end
post '/test/:key/dbinsert/yom' do
  redirect '/login' unless login?
  @notif = Notifications.get_all()
  @cssimport = Array.new
  @style = 'bootstrap'
  if(params[:key] == 'PRHAKEY')
    idct = 0;
    while(true)
      params[:yardwinnerdata]['id'] = idct;
      if(idct >= 1000)
        @errdetail = '0x2'
        slim :error
        break
      end
      begin
        @yomwinner = Yardwinners.new(params[:yardwinnerdata])
	      @yomwinner.save
	      break
      rescue
        idct = idct + 1;
      end
    end
    slim :test_dbinsert_yom
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
    @items = Residents.all
    slim :member_directory
  elsif(params[:page] == 'docs')
    @PageTitle = "Documents - Residents Dashboard"
    @items = Docs.all
    slim :member_docs
  elsif(params[:page] == 'yom')
    @PageTitle = "Yard of the Month - Residents Dashboard"
    @items = Yardwinners.all
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