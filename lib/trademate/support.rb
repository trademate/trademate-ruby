module Trademate
  module Support
    
    def self.included(base)
      base.extend ClassMethods
    end
    
    module ClassMethods
      
      def class_attribute(*attrs)
        attrs.each do |name|
          define_singleton_method(name) { nil }

          ivar = "@#{name}"

          define_singleton_method("#{name}=") do |val|
            singleton_class.class_eval do
              undef_method(name) if method_defined?(name) || private_method_defined?(name)
              define_method(name) { val }
            end

            if singleton_class?
              class_eval do
                undef_method(name) if method_defined?(name) || private_method_defined?(name)
                define_method(name) do
                  if instance_variable_defined? ivar
                    instance_variable_get ivar
                  else
                    singleton_class.send name
                  end
                end
              end
            end
            val
          end

          undef_method(name) if method_defined?(name) || private_method_defined?(name)
          define_method(name) do
            if instance_variable_defined?(ivar)
              instance_variable_get ivar
            else
              self.class.public_send name
            end
          end

          attr_writer name
        end
      end

      private
      
      def assert_valid_keys(hash, *valid_keys)
        valid_keys.flatten!
        unknown = hash.keys - valid_keys
        raise ArgumentError.new("Unknown keys: #{unknown.inspect}. Valid keys are: #{valid_keys.map(&:inspect).join(', ')}") if unknown.any?
      end

    end
  
  end
end
