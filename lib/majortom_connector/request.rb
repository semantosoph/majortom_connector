require 'httparty'
require 'net/http'

module MajortomConnector
  class Request

    AVAILABLE_COMMANDS = [
      "topics",
      "topicmaps",
      "resolvetm",
      "xtm",
      "ctm",
      "tmql",
      "sparql",
      "beru",
      "clearcache"
    ]

    attr_reader :result

    def self.call(config, command, query)
      new(config).run(command, query)
    end

    def self.available_commands
      AVAILABLE_COMMANDS
    end

    def self.command_available?(command)
      available_commands.include?(command)
    end

    def initialize(config)
      @mts_config = config
    end

    def run(command, param = "")
      raise ArgumentError, "Command #{command} not available. Try one of the following: #{MajortomConnector::Request.available_commands.join(', ')}" unless self.class.command_available?(command)
      @mts_result = Result.new
      post(command, param) if %w[tmql sparql beru].include?(command)
      get(command, param) if %w[topics topicmaps resolvetm clearcache].include?(command)
      stream(command) if %w[xtm ctm].include?(command)
      return @mts_result
    end

    def successful?
      @mts_result.successful?
    end

    protected

    def get(command, query = "")
      @mts_result.parse(HTTParty.get("#{server_uri}/tm/#{command}#{parameter_builder(command, query)}"))
    end

    def post(command, query)
      post_options = {:body => {:query => query, :apikey => @mts_config['user']['api_key']}}
      @mts_result.parse(HTTParty.post("#{server_uri}/tm/#{command}/#{@mts_config['map']['id']}/", post_options))
    end

    def stream(command)
      buffer = ""
      response = Net::HTTP.get_response(URI.parse("#{@mts_config['server']['host']}:#{@mts_config['server']['port']}/#{@mts_config['server']['context']}/tm/#{command}/#{@mts_config['map']['id']}?apikey=#{@mts_config['user']['api_key']}")) do |response|
        response.read_body do |segment|
          buffer << segment
        end
      end
      @mts_result.parse({'code' => response.code, 'msg' => response.message, 'data' => buffer})
    end

    def server_uri
      "#{@mts_config['server']['host']}:#{@mts_config['server']['port']}/#{@mts_config['server']['context']}"
    end

    def parameter_builder(command, query = "")
      parameter = case command
      when 'topics', 'clearcache' then "/#{@mts_config['map']['id']}?"
      when 'resolvetm' then "?bl=#{query}&"
      else "?"
      end << "apikey=#{@mts_config['user']['api_key']}"
    end
  end
end
