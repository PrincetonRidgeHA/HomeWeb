#!/usr/bin/env ruby
require 'rubygems'
require 'rest-client'
require 'json'
require 'csv'
require 'sinatra/activerecord'
require_relative '../config/environments'
require_relative '../frontend/models/residents.rb'
require_relative '../frontend/models/docs.rb'
require_relative '../frontend/models/yard_winners.rb'
require_relative '../frontend/models/news.rb'

while(true)
{
    # Check for items in MQ
    while(true)
    {
        # Run all tasks in MQ
    }
    # Wait five seconds before checking again
    sleep(5);
}