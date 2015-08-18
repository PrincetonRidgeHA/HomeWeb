#!/usr/bin/env ruby
require 'rubygems'
require 'sinatra'
require 'slim'
require 'rest-client'
require 'json'
require_relative 'inc/builddata'
require_relative 'inc/pagevars'

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
  @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
  @PageTitle = "Home"
  slim :home
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
get '/secured/:page' do
  redirect '/login' unless login?
  @TRAVISBUILDNUMBER = Pagevars.setVars("CIbuild")
  if(params[:page] == 'home')
    @PageTitle = "Home - Residents Dashboard"
    slim :membershome
  else
    redirect '/secured'
  end
end
get '/secured' do
  redirect '/login' unless login?
  redirect '/secured/home'
end
