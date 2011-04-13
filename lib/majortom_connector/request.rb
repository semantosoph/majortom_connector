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
      @config = config
    end

    def run(command, query = "")
      raise ArgumentError, "Command #{command} not available. Try one of the following: #{const_get(:AvailableCommands).join(',')}" unless self.class.command_available?(command)
      @result = Result.new
      return post(command, query) if %w[tmql sparql beru].include?(command)
      return get(command, query) if %w[topics topicmaps resolvetm].include?(command)
    end

    def successful?
      @result.successful?
    end

    protected

    def get(command, query = "")
      parameter = "/#{@config['map']['id']}" if command == 'topics'
      parameter = "?bl=#{query}" unless query.blank?
      @result.parse(HTTParty.get("#{server_uri}/tm/#{command}#{parameter}"))
    end

    def post(command, query)
      post_options = {:body => {:query => query}}
      @result.parse(HTTParty.post("#{server_uri}/tm/#{command}/#{@config['map']['id']}/", post_options))
      return @result
    end

    def xtm
    end

    def ctm
    end

    protected

    def server_uri
      "#{@config['server']['host']}:#{@config['server']['port']}/#{@config['server']['context']}"
    end
  end
end
