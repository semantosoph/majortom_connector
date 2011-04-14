require 'json'

module MajortomConnector
  class Result

    attr_reader :http_status
    attr_reader :http_message
    attr_reader :http_body

    attr_reader :code
    attr_reader :message
    attr_reader :data
    
    def request_successful?
      @http_status == "200" ? true : false
    end

    def response_successful?
      @code == "0" ? true : false
    end
    
    def parse(response, format = "", buffer = nil)
      @http_status = response.code
      @http_message = response.message
      @http_body = response.read_body

      return unless @http_status == "200"
      
      case format
      when 'xtm', 'ctm'
        @code = "0"
        @data = buffer
      when 'html'
        @code = "0"
      else
        json = JSON.parse(@http_body)
        @data = json['data']
        @code = json['code']
        @message = json['msg']
      end
    end
  end
end
