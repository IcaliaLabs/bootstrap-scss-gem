# frozen_string_literal: true

module Bootstrap
  module Scss
    class Engine < ::Rails::Engine
      initializer :assets do |app|
        app.config.assets.paths << root.join('vendor', 'assets', 'stylesheets')
      end
    end
  end
end
