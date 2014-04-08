#!/usr/bin/env ruby
require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'dm-transactions'
require 'json'
require_relative 'lib/bag'
require 'sinatra/namespace'

class BagitServer < Sinatra::Base
  register Sinatra::Namespace

  configure do
    set :configuration, YAML.load_file('./bagit_server.yml')[settings.environment.to_s]
    DataMapper.setup(:default, settings.configuration['db_connection_string'])
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  post '/bags' do
    data = JSON.parse(request.body.read)
    bag_id = data['id']
    halt(400, "Invalid id: #{bag_id}") if bag_id.nil? or bag_id.empty?
    version_id = data['version']
    bag = Bag.ensure_bag(bag_id)
    halt(409, "Version already exists: #{version_id}") if bag and bag.versions.first(version_id: version_id)
    version = bag.ensure_version(version_id)
    [201, {'Location' => "/bags/#{version.url_path}"}, "Hello"]
  end

  namespace '/bags/:bag_id' do

    before do
      @bag = Bag.first(bag_id: params[:bag_id])
      halt(404, "Bag #{params[:bag_id]} not found") unless @bag
    end

    delete do
      @bag.destroy
      return [200, "Bag deleted"]
    end

    namespace '/versions/:version_id' do
      before do
        @version = @bag.versions.first(version_id: params[:version_id])
        halt(404, "Version #{params[:version_id]} not found") unless @version
      end

      #for these files there are no prerequisites
      put '/bagit.txt' do
        @version.write_to_path('bagit.txt', request.body)
        [201, 'Content written']
      end

      put '/bag-info.txt' do
        @version.write_to_path('bag-info.txt', request.body)
        [201, 'Content written']
      end

    end
  end

end
