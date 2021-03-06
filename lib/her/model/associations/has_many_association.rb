module Her
  module Model
    module Associations
      class HasManyAssociation < Association
        # @private
        def self.attach(klass, name, attrs)
          attrs = {
            :class_name     => name.to_s.classify,
            :name           => name,
            :data_key       => name,
            :path           => "/#{name}",
            :inverse_of => nil
          }.merge(attrs)
          klass.associations[:has_many] << attrs

          klass.instance_eval do
            define_method(name) do
              cached_name = :"@_her_association_#{name}"

              cached_data = (instance_variable_defined?(cached_name) && instance_variable_get(cached_name))
              cached_data || instance_variable_set(cached_name, Her::Model::Associations::HasManyAssociation.new(self, attrs))
            end
          end
        end

        def build(attributes = {})
          @klass.new(attributes.merge(:"#{@parent.singularized_resource_name}_id" => @parent.id))
        end

        def create(attributes = {})
          resource = build(attributes)

          if resource.save
            @parent.attributes[@name] ||= Her::Collection.new
            @parent.attributes[@name] << resource
          end

          resource
        end

        # @private
        def fetch
          return Her::Collection.new if @parent.attributes.include?(@name) && @parent.attributes[@name].empty? && @query_attrs.empty?

          output = if @parent.attributes[@name].blank? || @query_attrs.any?
            path = begin
              @parent.request_path(@query_attrs)
            rescue Her::Errors::PathError
              return nil
            end

            @klass.get_collection("#{path}#{@opts[:path]}", @query_attrs)
          else
            @parent.attributes[@name]
          end

          inverse_of = @opts[:inverse_of] || @parent.singularized_resource_name
          output.each { |entry| entry.send("#{inverse_of}=", @parent) }

          output
        end
      end
    end
  end
end
