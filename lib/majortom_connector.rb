require 'majortom_connector/config'
require 'majortom_connector/connector'
require 'majortom_connector/result'
require 'majortom_connector/request'

module MajortomConnector
  
  def self.connect(id_or_base_iri = "")
    raise ArgumentError, 'Parameter must not be blank' if id_or_base_iri.blank?
    connector = Connector.new(id_or_base_iri)
  end
end
