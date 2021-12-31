# frozen_string_literal: true

require 'bootstrap/scss/version'

module Bootstrap
  module Scss
    GEM_PATH = File.expand_path '..', File.dirname(__FILE__)
    ASSETS_PATH = File.join GEM_PATH, 'vendor', 'assets'

    class << self
      def load!
        if rails?
          register_rails_engine
        elsif hanami?
          register_hanami
        elsif sprockets?
          register_sprockets
        elsif defined?(::Sass) && ::Sass.respond_to?(:load_paths)
          # The deprecated `sass` gem:
          ::Sass.load_paths << ASSETS_PATH
        end

        if defined?(::Sass::Script::Value::Number)
          # Set precision to 6 as per:
          # https://github.com/twbs/bootstrap/blob/da717b03e6e72d7a61c007acb9223b9626ae5ee5/package.json#L28
          ::Sass::Script::Value::Number.precision = [6, ::Sass::Script::Value::Number.precision].max
        end
      end

      # Environment detection helpers
      def sprockets?
        defined?(::Sprockets)
      end

      def rails?
        defined?(::Rails)
      end

      def hanami?
        defined?(::Hanami)
      end

      private

      def register_rails_engine
        require 'bootstrap/scss/engine'
      end

      def register_sprockets
        Sprockets.append_path ASSETS_PATH
      end

      def register_hanami
        Hanami::Assets.sources << ASSETS_PATH
      end
    end
  end
end

Bootstrap::Scss.load!
