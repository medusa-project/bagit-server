#!/usr/bin/env ruby
require 'sinatra/base'
require 'dm-core'
require 'dm-migrations'
require 'dm-transactions'
require 'json'
require_relative 'lib/bag'
require 'sinatra/namespace'
require 'sinatra/reloader'

class BagitServer < Sinatra::Base
  register Sinatra::Namespace

  configure do
    set :configuration, YAML.load_file('./bagit_server.yml')[settings.environment.to_s]
    DataMapper.setup(:default, settings.configuration['db_connection_string'])
    DataMapper.finalize
    DataMapper.auto_upgrade!
  end

  configure :development do
    register Sinatra::Reloader
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

      namespace '/contents' do
        #for these files there are no prerequisites
        #TODO possibly use custom matcher
        put '/bagit.txt' do
          @version.protected_write_to_path('bagit.txt', request.body)
          [201, 'Content written']
        end

        put '/bag-info.txt' do
          @version.protected_write_to_path('bag-info.txt', request.body)
          [201, 'Content written']
        end

        put '/:tag_file' do
          halt [400, 'Version does not yet have both bagit.txt and bag-info.txt '] unless @version.has_bag_files?
          file = params[:tag_file]
          begin
            @version.protected_write_to_path(file, request.body) do
              @version.update_manifest_if_manifest(file)
            end
          rescue BadManifestException => e
            halt [400, "Manifest Error: #{e.message}"]
          end
          [201, 'Content written']
        end

        put '/data/*' do
          halt [400, 'Version does not yet have both bagit.txt and bag-info.txt'] unless @version.has_bag_files?
          halt [400, 'Version does not have a manifest'] unless @version.manifests.count > 0
          splat = params[:splat]
          path = File.join('data' , splat)
          begin
            @version.protected_write_to_path(path, request.body) do
              @version.verify_data_file(path)
            end
          rescue FileNotInManifestException
            halt [400, "#{path} is not in any manifest"]
          rescue IncorrectChecksumException
            halt [400, 'Incorrect checksum']
          end
          [201, 'Content written']
        end

        get '/*' do
          path = File.join(params[:splat])
          full_path = File.join(@version.path, path)
          halt [404, "File #{path} not found"] unless File.exists?(full_path)
          File.open(full_path) do |file|
            [200, {'Content-Type' => 'application/octet-stream'}, file.read]
          end
        end

      end
    end

  end
end