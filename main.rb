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
require_relative 'inc/pagevars'
require_relative 'inc/mailer'

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
  def devenv?
    if ENV['RACK_ENV'] == 'test'
      return true
    else
      return false
    end
  end
end

get '/' do
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Home"
  @notif = Notifications.get_all()
  slim :home
end
get '/api/v1/get/:region/:item/:dtype' do
	if params[:region] == 'yom'
		if params[:item] == 'current'
			if params[:dtype] == 'imgpath'
				# Output the path to the image
				"http://princetonridge.com/Entry.JPG"
			end
		else
			# Read format using MM-YYYY
		end
	end
end
get '/contact' do
  @notif = Notifications.get_all()
  slim :bugreport
end
post '/contact' do
  @notif = Notifications.get_all()
  slim :processing
  Mailer.send(Pagevars.set_vars("ADMINMAIL"), "AUTO: PRHA bug report", params[:msgbody])
  redirect '/'
end
get '/login' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Sign in"
  slim :login
end
post '/login' do
  @notif = Notifications.get_all()
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  @PageTitle = "Sign in"
  if(params[:inputPassword] == 'test')
    session[:authusr] = true
    redirect '/secured'
  else
    @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
    @PageTitle = "Sign in"
    slim :login
  end
end
get '/test/:key/processing' do
  @notif = Notifications.get_all()
  if(params[:key] == 'PRHAKEY')
    slim :processing
  else
    slim :error
  end
end
get '/test/:key/dbinsert/resident' do
  @notif = Notifications.get_all()
  if(params[:key] == 'PRHAKEY')
    slim :test_dbinsert_resident
  else
    slim :error
  end
end
post '/test/:key/dbinsert/resident' do
  @notif = Notifications.get_all()
  if(params[:key] == 'PRHAKEY')
    @residents = Residents.new(0, 
      params[:residents]['name'],
      params[:residents]['addr'],
      params[:residents]['email'],
      params[:residents]['pnum'])
	  if @residents.save
		  slim :test_dbinsert_resident
	  else
		  "Sorry, there was an error!"
	  end
  else
    slim :error
  end
end
get '/secured/:page' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.set_vars("CIbuild")
  if(params[:page] == 'home')
    @PageTitle = "Home - Residents Dashboard"
    @items = Residents.all
    @notif = Notifications.get_all()
    slim :membershome
  else
    redirect '/secured'
  end
end
get '/secured' do
  redirect '/login' unless login?
  redirect '/secured/home'
end
