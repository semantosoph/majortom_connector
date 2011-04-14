module MajortomConnector
  class Request
    
    AVAILABLE_COMMANDS = {
      'topics' => 'topics',
      'topicmaps' => 'list_maps',
      'resolvetm' => 'find_topic_map_id_by_base_iri',
      'xtm' => 'to_xtm',
      'ctm' => 'to_ctm',
      'tmql' => 'tmql',
      'sparql' => 'sparql',
      'beru' => 'search',
      'clearcache' => 'clear_cache',
      'connectiontest' => 'established?'
    }

    attr_reader :result

    
    def self.available_commands
      AVAILABLE_COMMANDS
    end

    def self.command_available?(command)
      available_commands.keys.include?(command)
    end

    def initialize(config)
      @config = config
    end

    def run(command, param = "")
      raise ArgumentError, "Command #{MajortomConnector::Request.available_commands[command]} not available. Try one of the following: #{MajortomConnector::Request.available_commands.values.join(', ')}" unless self.class.command_available?(command)
      @result = Result.new
      post(command, param) if %w[tmql sparql beru].include?(command)
      get(command, param) if %w[topics topicmaps resolvetm clearcache].include?(command)
      stream(command) if %w[xtm ctm].include?(command)
      test if %w[connectiontest].include?(command)
      return @result
    end

    def successful?
      @result.result_successful?
    end
    
    def get(command, query = "")
      @result.parse(Net::HTTP.get_response(URI.parse("#{server_uri}/tm/#{command}#{parameter_builder(command, query)}")))
    end

    def post(command, query)
      @result.parse(Net::HTTP.post_form(URI.parse("#{server_uri}/tm/#{command}/#{@config.map_id}/"), {:query => query, :apikey => @config.api_key}))
    end

    def stream(command)
      buffer = ""
      response = Net::HTTP.get_response(URI.parse("#{server_uri}/tm/#{command}/#{@config.map_id}?apikey=#{@config.api_key}")) do |res|
        res.read_body do |segment|
          buffer << segment
        end
      end
      @result.parse(response, command, buffer)
    end

    def test
      @result.parse(Net::HTTP.get_response(URI.parse("#{server_uri}/")), 'html')
    end

    protected

    def server_uri
      "#{@config.host}:#{@config.port}/#{@config.context}"
    end

    def parameter_builder(command, query = "")
      parameter = case command
      when 'topics', 'clearcache' then "/#{@config.map_id}?"
      when 'resolvetm' then "?bl=#{query}&"
      else "?"
      end << "apikey=#{@config.api_key}"
    end
  end
end
