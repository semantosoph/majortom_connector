require 'pathname'

dir = Pathname(__FILE__).dirname.expand_path

require dir + 'majortom_connector/result'
require dir + 'majortom_connector/request'

module MajortomConnector
  def self.connect(id_or_base_iri = "")
    raise ArgumentError, 'Parameter must not be blank' if id_or_base_iri.blank?
    id = id_or_base_iri.match(/^http/) ? find_topic_map_id_by_base_iri(id_or_base_iri) : id_or_base_iri
    config.merge!({'map' => {'id' => id}})
  end

  def self.topic_map_id
    config['map']['id'] ||= ""
  end

  def self.list_maps
    request.run('topicmaps')
  end

  def self.find_topic_map_id_by_base_iri(base_iri)
    request.run('resolvetm', base_iri).data
  end

  def self.topics
    request.run('topics')
  end

  def self.tmql(query)
    request.run('tmql', query)
  end

  def self.sparql(query)
    request.run('sparql', query)
  end

  def self.search(query = "")
    request.run('beru', query)
  end

  def self.to_xtm
    request.run('xtm')
  end

  def self.to_ctm
    request.run('ctm')
  end

  protected
  
  def self.request
    @mts_request ||= Request.new(config)
  end

  def self.config
    @mts_config ||= load_server_config
  end

  def self.load_server_config
    YAML.load_file(File.join(::Rails.root, 'config', 'majortom-server.yml'))
  end
end
