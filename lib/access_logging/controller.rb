require 'active_support/concern'

module AccessLogging::Controller
  extend ActiveSupport::Concern
  
  module ClassMethods
    
    # example usage:
    #
    #   class ReportsController < ActionController::Base
    #     log_access_to :report, through: :print
    #
    #     # restful actions here...
    #
    #     def print
    #       @report = Report.find(params[:id])
    #     end
    #   end
    #
    # Also depends on the presence of a `current_anyone` method (probably on
    # ApplicationController) to determine the user.
    def log_access_to(model, opts={})
      after_filter(only: :index) do
        log_access
      end
    
      after_filter only: [:show, :create, :edit, :update, :destroy] do
        log_access instance_variable_get("@#{model}")
      end
    
      if opts[:through]
        opts[:through] = [ *opts[:through] ]
        opts[:through].each do |action|
          after_filter only: action do
            log_access instance_variable_get("@#{model}"), "#{action}ed"
          end
        end
      end
    end
  end
  
  # An alternative to a controller-wide filter (above) -- call something like
  # `log_access(@report, 'transmogrifying')` anywhere in an action.
  def log_access(object=nil, verb=nil)
    return unless current_anyone
    AccessLog.log_request current_anyone, request, model: object, verb: verb
  rescue => e
    # in production, don't kill the request just because logging failed
    raise e if Rails.env.development? || Rails.env.test?
  end
end