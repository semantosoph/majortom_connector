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
      @result = Result.new
    end

    def run(command, query = "")
      raise ArgumentError, "Command #{command} not available. Try one of the following: #{const_get(:AvailableCommands).join(',')}" unless self.class.command_available?(command)
      send(command, query)
    end

    def successful?
      @result.successful?
    end

    protected

    def topics
    end

    def topicmaps
    end

    def resolvetm(base_iri)
      @result.parse(HTTParty.get("#{server_uri}/tm/resolvetm?bl=#{base_iri}"))
    end

    def xtm
    end

    def ctm
    end

    def tmql(query)
      post_options = {:body => {:query => query}}
      @result.parse(HTTParty.post("#{server_uri}/tm/tmql/#{@config[:map][:id]}/", post_options))
      return @result
    end

    def sparql
    end

    def beru
    end
    
    protected
    
    def server_uri
      "#{@config['server']['host']}:#{@config['server']['port']}/#{@config['server']['context']}"
    end
  end
end