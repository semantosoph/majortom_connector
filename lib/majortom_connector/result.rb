module MajortomConnector
  class Result

    attr_reader :code

    attr_reader :message

    attr_reader :data
    
    attr_reader :format

    attr_reader :jtmqr
    
    def successful?
      @code == "0" ? true : false
    end
    
    def parse (result)
      @code = result['code']
      @message = result['msg']
      @data = result['data']
      
      if @data.kind_of?(Hash) && @data.has_key?('version')
        send("handle_jtmqr_v#{@data['version'].to_i}")
      end
    end

    protected
    
    def handle_jtmqr_v1
      @jtmqr = Array.new
      @data['seq'].each do |tupel|
        cells = Array.new
        tupel['t'].each do |c|
          cells << c[c.keys.first]
        end
        @jtmqr << cells
      end
    end
    
    def handle_jtmqr_v2
    end
  end
end
