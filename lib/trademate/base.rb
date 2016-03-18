module Trademate
  class Base
    include Support

    class_attribute :attributes
    self.attributes = []
    
    class << self
      def endpoint(**options)
        assert_valid_keys options, :lookup, :action
        path = endpoint_name
        path << "/#{options[:lookup]}" if options.key?(:lookup)
        path << "/#{options[:action]}" if options.key?(:action)
        path << ".json"
      end
      
      def attr_accessible(*attrs)
        attrs = attrs.map(&:to_s)
        attrs.each do |attr|
          define_method(attr) { read_attribute(attr) }
          define_method("#{attr}=") { |value| write_attribute(attr, value) }
        end
        self.attributes = (attributes + attrs).uniq
      end
      
      def attr_readable(*attrs)
        attrs.each do |attr|
          define_method(attr) { read_attribute(attr) }
        end
      end
      
      def attribute?(name)
        attributes.include?(name.to_s)
      end
      
      def serialize_attributes(attrs)
        attrs.select { |attr, value| attribute?(attr) }
      end
      
      def serialize_attributes!(attrs)
        illegal_attrs = attrs.keys.map(&:to_s) - attributes
        raise ArgumentError, "Illegal attributes: #{illegal_attrs}" if illegal_attrs.any?
        serialize_attributes(attrs)
      end
      
      def updatable
        include Operations::Update
      end
      
      def destroyable
        include Operations::Destroy
      end
      
      def timestamped
        # TODO
      end
      
      # private
      
      # FIXME! use proper inflection
      def root
        name.split('::').last.downcase
      end
      
      def endpoint_name
        "#{root}s"
      end
      
    end

    attr_readable :id
    
    def initialize(api, attrs = {})
      raise ArgumentError, "#{api.inspect} is not a Trademate::API" unless api.is_a?(API)
      @api = api
      self.attributes = attrs if attrs
    end

    #def valid?
    #  true
    #end
  
    def attributes=(attrs)
      attrs.each_pair do |attr, value|
        if respond_to?("#{attr}=")
          public_send("#{attr}=", value)
        else
          attributes[attr.to_s] = value
        end
      end
    end
  
    def attributes
      @attributes ||= {}
    end
    
    def attributes_for_serialization
      self.class.serialize_attributes(attributes)
    end
    
    def params_for_serialization
      extra_params.merge(self.class.root => attributes_for_serialization)
    end
    
    def endpoint(**options)
      options[:lookup] = id unless options.has_key?(:lookup)
      self.class.endpoint(**options)
    end
    
    #def persisted?
    #  id && id != '' && id != 0
    #end
        
    def inspect
      attrs_inspect = @attributes.inspect
      attrs_inspect = attrs_inspect[0..1000] + ' ... }' if attrs_inspect.size > 1000
      "#<#{self.class} @attributes=#{attrs_inspect}>"
    end
    
    private
    
    def api
      @api
    end

    def extra_params
      @extra_params ||= {}
    end
    
    def read_attribute(attr)
      attributes[attr.to_s]
    end
    
    def write_attribute(attr, value)
      attributes[attr.to_s] = value
    end
  end
end
