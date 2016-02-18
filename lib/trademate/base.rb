module Trademate
  class Base
    include Support

    class_attribute :attributes
    self.attributes = []
    
    class << self
      def api_path(*args)
        raise ArgumentError, "Wrong number of arguments (#{args.size} for 1)" if args.size > 1
        path = "#{name.split('::').last.downcase}s"
        path << "/#{args.first}" if args.size > 0
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
      
      def collection(*names)
        names.each do |name|
          define_method(name) { read_attribute(name) || [] }
          define_method("#{name}=") { |value| write_attribute(name, value) }
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
    
    #def persisted?
    #  id && id != '' && id != 0
    #end
        
    def inspect
      "#<#{self.class} @attributes=#{@attributes.inspect}>"
    end
    
    private
    
    def api
      @api
    end
    
    def read_attribute(attr)
      attributes[attr.to_s]
    end
    
    def write_attribute(attr, value)
      attributes[attr.to_s] = value
    end
  end
end
