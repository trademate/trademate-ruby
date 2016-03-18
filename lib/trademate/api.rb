module Trademate
  class API
    
    API_HOST    = 'trademate.de'
    API_VERSION = '1.0'
    API_PORT    = 443
    
    [:credentials, :host, :port, :version, :disable_ssl].each do |reader|
      attr_reader reader
      private reader
    end
    
    def initialize(consumer_key, consumer_secret, token, token_secret, options = {})
      @credentials = OoAuth::Credentials.new(consumer_key, consumer_secret, token, token_secret)
      @host = options[:host] || API_HOST
      @port = options[:port] || API_PORT
      @version = options[:version] || API_VERSION
      @disable_ssl = !!options[:disable_ssl]
      puts "\n**** WARNING: disabled SSL for development mode ****\n\n"
    end
    
    def destroy(base)
      delete base.endpoint
    end
    
    def update(base)
      put(base.endpoint, base.params_for_serialization)
    end
    
    [Item, Attachment].each do |klass|
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
      define_method "lookup_#{name}" do |*args|
        case args.size
        when 1 then find(klass, lookup(nil, args.first))
        when 2 then find(klass, lookup(args.first, args.second))
        else
          raise ArgumentError, "wrong number of arguments (#{args.size} for 1..2)"
        end
      end
    end
        
    private
    
    def lookup(key, value)
      "#{key}~#{value}"
    end
    
    def create(klass, attributes)
      base = build(klass, attributes)
      build klass, post(klass.endpoint, base.params_for_serialization)
    end

    def find(klass, id)
      build klass, get(klass.endpoint(lookup: id))
    end
    
    def all(klass, options = {})
      get(klass.endpoint, options).map { |attributes| build klass, attributes }
    end
    
    def build(klass, attributes)
      klass.new(self, attributes)
    end
    
    def assign(instance, attributes)
      instance.attributes = attributes
      instance
    end
    
    def get(path, params = nil)
      parse(execute(init_request(:get, api_path(path, params))))
    end
    
    def post(path, params = nil)
      request = init_request(:post, api_path(path))
      set_body(request, params)
      #request.set_form_data(normalize_params(params)) if params
      parse(execute(request))
    end
    
    def put(path, params = nil)
      request = init_request(:put, api_path(path))
      set_body(request, params)
      #request.set_form_data(normalize_params(params)) if params
      execute request
      true
    end
    
    def delete(path, params = nil)
      execute init_request(:delete, api_path(path, params))
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
      @https.use_ssl = !disable_ssl
      @https
    end
    
    def execute(request)
      response = https.start { |https| https.request(request) }
      log_response(response)
      response_code = response.code.to_i
      raise AuthenticationError if 401 == response_code
      raise APIError if response_code >= 500
      raise NotFoundError if 404 == response_code
      raise APIError, "Server returned status #{response_code}" unless 2 == response_code / 100
      response
    end
    
    def parse(request)
      JSON.parse(request.body)
    end
    
    def uri_class
      disable_ssl ? URI::HTTP : URI::HTTPS
    end
    
    def api_path(endpoint, params = nil)
      encoded_params = "?#{URI.encode_www_form(params)}" if params && !params.empty?
      "/ws/#{version}/#{endpoint}#{encoded_params}"
    end
    
    def log_response(response)
      # TODO: logger.info response.inspect
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
    
    def set_body(request, params)
      request['Content-Type'] = 'application/json'
      request.body = params.to_json
    end
    
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
