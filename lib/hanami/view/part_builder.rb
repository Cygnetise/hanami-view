# frozen_string_literal: true

require "dry/core/cache"
require "dry/core/equalizer"
require "dry/effects"
require "dry/inflector"
require_relative "part"

module Hanami
  class View
    # Decorates exposure values with matching parts
    #
    # @api private
    class PartBuilder
      extend Dry::Core::Cache
      include Dry::Equalizer(:inflector, :namespace)

      attr_reader :inflector
      attr_reader :namespace

      # Returns a new instance of PartBuilder
      #
      # @api private
      def initialize(inflector: Dry::Inflector.new, namespace: nil)
        @inflector = inflector
        @namespace = namespace
      end

      # Decorates an exposure value
      #
      # @param name [Symbol] exposure name
      # @param value [Object] exposure value
      # @param options [Hash] exposure options
      #
      # @return [Hanami::View::Part] decorated value
      #
      # @api private
      def call(name, value, **options)
        builder = value.respond_to?(:to_ary) ? :build_collection_part : :build_part

        send(builder, name, value, **options)
      end

      private

      def build_part(name, value, **options)
        klass = part_class(name: name, **options)

        klass.new(
          name: name,
          value: value
        )
      end

      def build_collection_part(name, value, **options)
        collection_as = options[:as].is_a?(Array) ? options[:as].first : nil
        item_name, item_as = collection_item_name_as(name, options[:as])

        arr = value.to_ary.map { |obj|
          build_part(item_name, obj, **options.merge(as: item_as))
        }

        build_part(name, arr, **options.merge(as: collection_as))
      end

      def collection_item_name_as(name, as)
        singular_name = singularize(name).to_sym
        singular_as =
          if as.is_a?(Array)
            as.last if as.length > 1
          else
            as
          end

        if singular_as && !singular_as.is_a?(Class)
          singular_as = singularize(singular_as)
        end

        [singular_name, singular_as]
      end

      def part_class(name:, fallback_class: Part, **options)
        fetch_or_store(:part_class, namespace, name, fallback_class) {
          name = options[:as] || name

          if name.is_a?(Class)
            name
          else
            resolve_part_class(name: name, fallback_class: fallback_class)
          end
        }
      end

      # rubocop:disable Metrics/PerceivedComplexity
      def resolve_part_class(name:, fallback_class:)
        return fallback_class unless namespace

        name = inflector.camelize(name.to_s)

        # Give autoloaders a chance to act
        begin
          klass = namespace.const_get(name)
        rescue NameError # rubocop:disable Lint/HandleExceptions
        end

        if !klass && namespace.const_defined?(name, false)
          klass = namespace.const_get(name)
        end

        if klass && klass < Part
          klass
        else
          fallback_class
        end
      end
      # rubocop:enable Metrics/PerceivedComplexity

      # TODO: add doc explaining that we cache this because it can be called a large number of times
      # due to building collections of parts
      def singularize(name)
        fetch_or_store(:singularize, name) { inflector.singularize(name.to_s) }
      end
    end
  end
end
