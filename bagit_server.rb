#!/usr/bin/env ruby
require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require_relative 'lib/bag'

class BagitServer < Sinatra::Base

  configure do
    set :configuration, YAML.load_file('./bagit_server.yml')[settings.environment.to_s]
    DataMapper.setup(:default, settings.configuration['db_connection_string'])
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  post '/bags' do
    data = JSON.parse(request.body.read)
    id = data['id']
    version_id = data['version']
    version = Bag.ensure_bag(id).ensure_version(version_id)
    [201, {'Location' => "/bags/#{id}/#{version_id}"}, "Hello"]
  end

end
