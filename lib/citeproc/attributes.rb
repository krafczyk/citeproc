
module CiteProc
  
	# TODO refactor using a Struct instead of a hash. This will have to convert
	# the CiteProc/CSL names which are no proper method names.
	
	
  module Attributes
    extend Forwardable
    

		FALSE_PATTERN = (/^(false|no|never)$/i).freeze
		
    def self.included(base)
      base.extend(ClassMethods)
    end
    
    def attributes
      @attributes ||= {}
    end
    
    def merge(other)
      return self if other.nil?
      
      case other
      when String, /^\s*\{/
        other = MulitJson.decode(other, :symbolize_keys => true)
      when Hash
				# do nothing
      when Attributes
        other = other.to_hash
			else
				raise ParseError, "failed to merge attributes and #{other.inspect}"
      end

      other.each_pair do |key, value|
				attributes[key.to_sym] = begin
					value.respond_to?(:deep_copy) ? value.deep_copy : value.dup
				rescue
					value
				end
			end
      
      self
    end

    alias update merge
    
		def reverse_merge(other)
			fail "not implemented yet"
		end

		def to_hash
			attributes.deep_copy
		end

		def_delegators :attributes, :empty?

    module ClassMethods

      def create(parameters)
        new.merge(parameters)
      end
      
      def attr_predicates(*arguments)
        arguments.flatten.each do |field|
          field, default = *(field.is_a?(Hash) ? field.to_a.flatten : [field]).map(&:to_s)
          attr_field(field, default, true)
        end
      end

      def attr_fields(*arguments)
        arguments.flatten.each do |field|
          attr_field(*(field.is_a?(Hash) ? field.to_a.flatten : [field]).map(&:to_s))
        end
      end
      
      def attr_field(field, default = nil, predicate = false)
        method_id = field.downcase.gsub(/[-\s]+/, '_')

        unless instance_methods.include?(method_id)
          if default
            define_method(method_id) do
              attributes[field.to_sym]
            end
          else
            define_method(method_id) do
              attributes[field.to_sym] ||= default
            end
          end
        end

        writer_id = [method_id,'='].join
        unless instance_methods.include?(writer_id)
          define_method(writer_id) do |value|
            attributes[field.to_sym] = value
          end
        end
        
        predicate_id = [method_id, '?'].join  
        if predicate && !instance_methods.include?(predicate_id)
          define_method(predicate_id) do
						v = attributes[field.to_sym]
						!(v.nil? || (v.respond_to?(:empty?) && v.empty?) || v =~ FALSE_PATTERN)
          end
          
          has_predicate = ['has_', predicate_id].join
          alias_method(has_predicate, predicate_id) unless instance_methods.include?(has_predicate)
        end
      end
    
    end
  
  end
end