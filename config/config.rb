
require 'grape'
require 'redis'
require 'json'
require 'singleton'
require 'uri'
require 'net/http'
require 'csv'

require './lib/janrain_service.rb'
require './lib/janrain.rb'


class Cfg
  include Singleton

  @config = {}
  @redis = Redis.new(url: ENV['REDISCLOUD_URL'] || 'redis://127.0.0.1:6379')
  @test_user_data = CSV.read('config/stg-enhanced-guid-emails.csv')
  @test_user_data_size = @test_user_data.size-1

  def self.config
    @config.clone
  end

  def self.test_user_data
    @test_user_data.clone
  end

  def self.get_random_test_user
    @test_user_data[rand(@test_user_data_size)+1]
  end

  def self.redis
    @redis
  end

  def self.get_redis_key(key)
  	Cfg.redis.call('GET', key)
  end

  def self.set_redis_key(key, value)
  	Cfg.redis.call('SET', key, value)
  end

  environments = Dir.glob('./config/*.json').select{ |f| File.file? f }.map { |f| File.basename(f, '.*' ) }
  abort 'Error: no any environments found to load (./config/*.json)' if environments.empty?

  @config = []
  @requestParameters = []

  if ENV['RAKE_ENV'] # create/migrate rake task
    if environments.include? ENV['RAKE_ENV']
      @config = JSON.parse(File.read("./config/#{ENV['RAKE_ENV']}.json"))
      @config[:env] = ENV['RAKE_ENV']
    else 
      puts "Error: no such environment found: #{ENV['RAKE_ENV']}"
      puts 'Available options to use:'
      environments.each do |env|
        puts "rake [task] RAKE_ENV=#{env}"
      end
      exit
    end
  else
    if environments.include? ENV['RACK_ENV']
      @config = JSON.parse(File.read("./config/#{ENV['RACK_ENV']}.json"))
      @config[:env] = ENV['RACK_ENV']
    else
      puts "Error: no such environment found: #{ENV['RACK_ENV']}"
      puts 'Available options to use:'
      environments.each do |env|
        puts "rackup -E #{env}"
        puts "rake [task] RAKE_ENV=#{env}"
      end
      exit
    end
    @config['flow_name'] ||= ENV['flow_name']
    @config['flow_version'] ||= ENV['flow_version']
    @config['client_id'] ||= ENV['client_id']
    @config['url'] ||= ENV['url']
    puts "config loaded: #{@config.inspect}"
  end # end rake / rack env loading


end # end cfg