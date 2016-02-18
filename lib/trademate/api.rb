module Trademate
  class API
    
    API_HOST    = 'trademate.de'
    API_VERSION = '1.0'
    API_PORT    = 443
    
    [:credentials, :host, :port, :version, :disable_ssl].each do |reader|
      attr_reader reader
      private reader
    end
    
    def initialize(consumer_key, consumer_secret, access_token, access_token_secret, options = {})
      @credentials = OoAuth::Credentials.new(consumer_key, consumer_secret, access_token, access_token_secret)
      @host = options[:host] || API_HOST
      @port = options[:port] || API_PORT
      @version = options[:version] || API_VERSION
      @disable_ssl = !!options[:disable_ssl]
      puts "\n**** WARNING: disabled SSL for development mode ****\n\n"
    end
    
    def destroy(base)
      delete base.class.api_path(base.id)
    end
    
    def update(base)
      assign base, put(base.class.api_path(base.id), base.attributes_for_serialization)
    end
    
    #[Payment, Transaction, Client].each do |klass|
    [Item].each do |klass|
      name = klass.name.split('::').last.downcase
      define_method "create_#{name}" do |attrs = {}|
        create klass, attrs
      end
      define_method "#{name}s" do |options = {}|
        all klass, options
      end
      define_method "find_#{name}" do |id|
        find klass, id
      end
      define_method "find_#{name}_by" do |lookup_key, lookup_value|
        find klass, lookup(lookup_key, lookup_value)
      end
    end
        
    private
    
    def lookup(key, value)
      "#{key}~#{value}"
    end
    
    def create(klass, attributes)
      build klass, post(klass.api_path, klass.serialize_attributes!(attributes))
    end

    def find(klass, id)
      puts "find #{klass}: #{klass.api_path(id)}"
      build klass, get(klass.api_path(id)).first
    end
    
    def all(klass, options = {})
      get(klass.api_path, options).map { |attributes| build klass, attributes }
    end
    
    def build(klass, attributes)
      klass.new(self, attributes)
    end
    
    def assign(instance, attributes)
      instance.attributes = attributes
      instance
    end
    
    def get(path, params = nil)
      execute init_request(:get, api_url(path, params))
    end
    
    def post(path, params = nil)
      request = init_request(:post, api_url(path))
      request.set_form_data(normalize_params(params)) if params
      execute request
    end
    
    def put(path, params = nil)
      request = init_request(:put, api_url(path))
      request.set_form_data(normalize_params(params)) if params
      execute request
    end
    
    def delete(path, params = nil)
      execute init_request(:delete, api_url(path, params))
    end
    
    def init_request(method, url)
      raise ArgumentError, "Illegal method #{method.inspect}" unless [:get, :post, :put, :delete].include?(method)
      request = Net::HTTP.const_get(method.to_s.capitalize).new(url)
      OoAuth.sign!(https, request, credentials)
      request
    end
    
    def https
      return @https if @https
      @https = Net::HTTP.new(host, port)
      @https.use_ssl = true unless disable_ssl
      @https
    end
    
    def execute(request)
      response = https.start { |https| https.request(request) }
      log_response(response)
      response_code = response.code.to_i
      raise AuthenticationError if 401 == response_code
      raise APIError if response_code >= 500
      raise NotFoundError if 404 == response_code
      payload = JSON.parse(response.body)
      raise APIError, payload['error'] if payload['error']
      raise APIError, "Server returned status #{response_code}" unless 2 == response_code / 100
      payload['data']
    end
    
    def uri_class
      disable_ssl ? URI::HTTP : URI::HTTPS
    end
    
    def api_url(path, params = nil)
      encoded_params = "?#{URI.encode_www_form(params)}" if params && !params.empty?
      #"http#{'s' unless disable_ssl}://#{host}/ws/#{version}/#{path}#{encoded_params}"
      uri_class.build(host: host, port: port, path: "/ws/#{version}/#{path}", query: encoded_params).to_s
    end
    
    def log_response(response)
      puts response.inspect
    end
    
=begin
    # FIXME: refactor
    def flatten_hash_keys(old_hash, new_hash = {}, keys = nil)
      old_hash.each do |key, value|
        key = key.to_s
        if value.is_a?(Hash)
          all_keys_formatted = keys + "[#{key}]"
          flatten_hash_keys(value, new_hash, all_keys_formatted)
        else
          new_hash[key] = value
        end
      end
      new_hash
    end
=end
    
    # TODO
    def normalize_params(params, key = nil)
      return params
    end

=begin
    # FIXME: refactor
    def normalize_params(params, key = nil)
      params = flatten_hash_keys(params) if params.is_a?(Hash)
      result = {}
      params.each do |key, value|
        case value
        when Hash
          result[key.to_s] = normalize_params(value)
        when Array
          value.each_with_index do |item_value, index|
            result["#{key.to_s}[#{index}]"] = item_value.to_s
          end
        else
          result[key.to_s] = value.to_s
        end
      end
      result
    end
=end
  end
end
