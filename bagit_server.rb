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
    bag_id = data['id']
    return [400, "Invalid id: #{bag_id}"] if bag_id.nil? or bag_id.empty?
    version_id = data['version']
    bag = Bag.ensure_bag(bag_id)
    return [409, "Version already exists: #{version_id}"] if bag and bag.versions.first(version_id: version_id)
    version = bag.ensure_version(version_id)
    p = version.url_path
    [201, {'Location' => "/bags/#{version.url_path}"}, "Hello"]
  end

end
