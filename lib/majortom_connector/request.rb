require 'httparty'

module MajortomConnector
  class Request

    AvailableCommands = [
      "topics",
      "topicmaps",
      "resolvetm",
      "xtm",
      "ctm",
      "tmql",
      "sparql",
      "beru"
    ]

    attr_reader :result

    def self.call(config, command, query)
      new(config).run(command, query)
    end

    def self.available_commands
      const_get(:AvailableCommands)
    end

    def self.command_available?(command)
      available_commands.include?(command)
    end

    def initialize(config)
      @mts_config = config
    end

    def run(command, query = "")
      raise ArgumentError, "Command #{command} not available. Try one of the following: #{const_get(:AvailableCommands).join(',')}" unless self.class.command_available?(command)
      @mts_result = Result.new
      post(command, query) if %w[tmql sparql beru].include?(command)
      get(command, query) if %w[topics topicmaps resolvetm clearcache xtm ctm].include?(command)
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

    def xtm
    end

    def ctm
    end

    def server_uri
      "#{@mts_config['server']['host']}:#{@mts_config['server']['port']}/#{@mts_config['server']['context']}"
    end

    def parameter_builder(command, query = "")
      parameter = case command
      when 'topics' then "/#{@mts_config['map']['id']}?"
      when 'resolvetm' then "?bl=#{query}&"
      else "?"
      end << "apikey=#{@mts_config['user']['api_key']}"
    end
  end
end
