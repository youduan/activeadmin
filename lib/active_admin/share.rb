module ActiveAdmin
  module Share
    DSLS = [ ActiveAdmin::DSL, ActiveAdmin::ResourceDSL, ActiveAdmin::PageDSL, ActiveAdmin::Filters::DSL ]

    class DSL
      attr_reader :store

      def initialize
        @store = Store.new
      end

      def respond_to_missing?(method_name, include_private = false)
        dsl_methods.include?(method_name) || super
      end

      def method_missing(method_name, *args, &block)
        if dsl_methods.include?(method_name)
          store.add method_name, [args, block]
        else
          super
        end
      end

      def dsl_methods
        @dsl_methods ||= begin
          _dsl_methods = []
          [:instance_methods, :private_instance_methods, :protected_instance_methods].each do |type|
            _dsl_methods += DSLS.map(&type).flatten
          end
          _dsl_methods -= Object.instance_methods
          _dsl_methods -= Object.private_instance_methods
          _dsl_methods -= Object.protected_instance_methods
          _dsl_methods.uniq
        end
      end
    end

    class Store
      attr_reader :entries

      def initialize
        @entries = Hash.new{ |hash, key| hash[key] = {} }
      end

      def add(share, method, args)
        entries[share][method] = args
      end

      def fetch(share, method)
        entries[share][method]
      end
    end
  end
end
