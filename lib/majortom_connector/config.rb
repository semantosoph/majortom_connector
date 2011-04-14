module MajortomConnector
  class Config
    
    attr_accessor :host, :port, :context, :api_key, :map_id
    
    def initialize
      load_server_config
    end

    def ready?
      !(@host.blank? || @port.blank? || @context.blank? || @api_key.blank?)
    end
    
    protected
    
    def load_server_config
      begin
        # Usual way of loading the configuration is from file.
        file_config = YAML.load_file(File.join(::Rails.root, 'config', 'majortom-server.yml'))
        @host = file_config['server']['host']
        @port = file_config['server']['port']
        @context = file_config['server']['context']
        @api_key = file_config['user']['api_key']
      rescue Exception
        # Wow! The config file was not there!
      end
    end
  end
end
