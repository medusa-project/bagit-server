#!/usr/bin/env ruby
require 'sinatra/base'

class BagitServer < Sinatra::Base

  post '/bags' do
    "Hello"
  end

end
