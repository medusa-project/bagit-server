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
    [201, {'Location' => "/bags/#{version.url_path}"}, "Version #{version.version_id} created in bag #{bag.bag_id}"]
  end

  namespace '/bags/:bag_id' do

    before do
      @bag = Bag.first(bag_id: params[:bag_id])
      halt(404, "Bag #{params[:bag_id]} not found") unless @bag
    end

    delete do
      @bag.destroy
      [200, 'Bag deleted']
    end

    namespace '/versions/:version_id' do
      before do
        @version = @bag.versions.first(version_id: params[:version_id])
        halt(404, "Version #{params[:version_id]} not found") unless @version
      end

      get '/validation' do
        [200, {'Content-Type' => 'application/json'}, @version.validation.to_json]
      end

      post '/fetch' do
        halt(405, "Version #{params[:version]} not in a state to fetch content") unless @version.accepts_content?
        @version.fetch
        [200, 'Fetch started']
      end

      post '/validate' do
        halt(405, "Version #{params[:version]} not in a state to validate content") unless @version.accepts_content?
        @version.validate
        [200, 'Validation started']
      end

      post '/commit' do
        halt(405, "Version #{params[:version]} not in a state to commit content") unless @version.commitable?
        @version.commit
        [200, 'Version committed']
      end

      namespace '/contents' do

        #check if uploading is allowed - if so pass, otherwise return a 405
        put '/*' do
          halt(405, "Version #{params[:version]} not in a state to accept content") unless @version.accepts_content?
          pass
        end

        #for these files there are no prerequisites
        #TODO possibly use custom matcher
        put '/bagit.txt' do
          begin
            @version.protected_write_to_path('bagit.txt', request.body) do
              @version.verify_bagit_file
            end
          rescue BadBagitFileException
            halt [400, 'Invalid bagit.txt file.']
          end
          [201, 'Content written']
        end

        put '/bag-info.txt' do
          begin
            @version.protected_write_to_path('bag-info.txt', request.body) do
              @version.verify_bag_info_file
            end
          rescue BadBagInfoFileException
            halt [400, 'Invalid bag-info.txt file']
          end
          [201, 'Content written']
        end

        put '/:tag_file' do
          halt [400, 'Version does not yet have both bagit.txt and bag-info.txt '] unless @version.has_bag_files?
          file = params[:tag_file]
          begin
            @version.protected_write_to_path(file, request.body) do
              @version.verify_tag_file(file)
            end
          rescue BadManifestException => e
            halt [400, "Manifest Error: #{e.message}"]
          rescue BadTagManifestException => e
            halt [400, "Tag Manifest Error: #{e.message}"]
          rescue IncorrectChecksumException
            halt [400, 'Incorrect Checksum']
          rescue BadFetchFileException => e
            halt [400, "Invalid fetch.txt file: #{e.message}"]
          end
          [201, 'Content written']
        end

        put '/data/*' do
          halt [400, 'Version does not yet have both bagit.txt and bag-info.txt'] unless @version.has_bag_files?
          halt [400, 'Version does not have a manifest'] unless @version.manifests.count > 0
          splat = params[:splat]
          path = File.join('data', splat)
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
          begin
            content = @version.read_content(path)
            [200, {'Content-Type' => 'application/octet-stream'}, content]
          rescue FileNotFound
            halt [404, "File #{path} not found"]
          end
        end

        delete '/*' do
          halt(405, "Version #{params[:version]} not in a state to delete content") unless @version.accepts_content_deletion?
          path = File.join(params[:splat])
          begin
            @version.delete_content(path)
          rescue FileNotFound
            halt [404, "File #{path} not found"]
          end
          status 204
        end

      end
    end

  end
end