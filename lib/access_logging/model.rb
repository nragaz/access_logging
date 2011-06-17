require 'active_support/concern'

module AccessLogging::Model
  extend ActiveSupport::Concern
  
  include Hms::Scopes::Date
  
  REDIS_ATTRIBUTES = [
    :created_at,
    :ip, :user_type, :user_id, 
    :verb, :model_type, :model_id, :description,
    :path
  ]
  
  REDIS_SEPARATOR = "||"
  
  included do
    belongs_to :user, polymorphic: true
    belongs_to :model, polymorphic: true
    
    before_validation :set_user_name_and_email, :set_description
    
    validates_presence_of :ip, :path, :verb,
                          :user_name, :user_email, :user_id, :user_type,
                          :created_at
    
    default_scope order('access_logs.created_at DESC')
  end
  
  module ClassMethods
    def log_request(user, request, opts={})
      log = AccessLog.new
      log.user = user
      log.path = request.fullpath
      log.ip = request.remote_ip
      
      log.model = opts[:model]
      log.verb = opts[:verb] || default_verb_for_method(request.request_method)
      
      return if log.model && log.model.new_record?
      
      log.save!
    end
  
    def default_verb_for_method(method)
      case method.to_s.upcase
      when 'GET'
        "viewed"
      when 'POST'
        "created"
      when 'PUT'
        "updated"
      when 'DELETE'
        "deleted"
      end
    end
  
    def build_from_redis_string(str)
      log = AccessLog.new
      parts = str.split(REDIS_SEPARATOR, -1)
    
      REDIS_ATTRIBUTES.each_with_index do |attribute, i|
        log.send "#{attribute}=", parts[i]
      end
    
      log
    end
  end
  
  def created_at
    self[:created_at] ||= Time.zone.now
  end
  
  def redis_string
    REDIS_ATTRIBUTES.map { |attribute| send(attribute) }.join(REDIS_SEPARATOR)
  end
  
  
  private
  
  def set_description
    self.description = "" and return unless model && !model.new_record?
    
    if model.respond_to?(:description)
      self.description = model.description
    elsif model.respond_to?(:name)
      self.description = "#{model.class.name} #{model.try(:name)}"
    else
      self.description = "#{model.class.name} #{model.id}"
    end
  end
  
  def set_user_name_and_email
    self.user_name = user.try :name
    self.user_email = user.try :email
  end
end