require 'active_support/dependencies'

ActiveSupport.on_load(:action_controller) do
  include AccessLogging::Controller
end

module AccessLogging
  autoload :Controller, 'access_logging/controller'
  autoload :Model,      'access_logging/model'
end