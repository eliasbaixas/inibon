require 'ancestry'

module Inibon
  class Engine < ::Rails::Engine
    isolate_namespace Inibon

    config.autoload_paths += Dir["#{config.root}/lib/**/"]
    config.autoload_paths += Dir[config.root.join('app', 'models', 'concerns')]

    # initializer "static assets" do |app|
    #   app.middleware.insert_before(::ActionDispatch::Static, ::ActionDispatch::Static, "#{root}/public")
    # end
  end
end
