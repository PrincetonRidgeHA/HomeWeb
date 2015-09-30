#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'slim'
require 'rest-client'
require 'json'
require 'sinatra/activerecord'
require './config/environments'
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
    #if session[:authusr].nil?
    #  return false
    #else
    #  return true
    #end
    return true
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
  @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
  @PageTitle = "Home"
  @notif = Notifications.getAll()
  slim :home
end
get '/contact' do
  slim :error
end
post '/contact' do
  slim :processing
  Mailer.send(Pagevars.setVars("ADMINMAIL"), "AUTO: PRHA bug report", params[:msgbody])
  redirect '/'
end
get '/login' do
  @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
  @PageTitle = "Sign in"
  slim :login
end
post '/login' do
  if(params[:inputPassword] == 'test')
    session[:authusr] = true
    redirect '/secured'
  else
    @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
    @PageTitle = "Sign in"
    slim :login
  end
end
get '/test/:key/processing' do
  if(params[:key] == 'PRHAKEY')
    slim :processing
  else
    slim :error
  end
end
get '/test/:key/dbinsert/resident' do
  if(params[:key] == 'PRHAKEY')
    slim :test_dbinsert_resident
  else
    slim :error
  end
end
post '/test/:key/dbinsert/resident' do
  if(params[:key] == 'PRHAKEY')
    @residents = Residents.new(params[:residents])
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
  @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
  if(params[:page] == 'home')
    @PageTitle = "Home - Residents Dashboard"
    @items = Residents.all
    @notif = Notifications.getAll()
    slim :membershome
  else
    redirect '/secured'
  end
end
get '/secured' do
  redirect '/login' unless login?
  redirect '/secured/home'
end
