AccessLogging
============

Log access to models through your controllers.

Requires Rails ~> 3 and Ruby 1.9.2.

Usage
-----

  create_table "access_logs" do |t|
    t.integer  "user_id"
    t.string   "user_type",   :limit => 16
    t.string   "user_email",  :limit => 100
    t.string   "ip",          :limit => 15
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "user_name",   :limit => 48
    t.string   "path",        :limit => 100
    t.string   "model_type",  :limit => 24
    t.integer  "model_id"
    t.string   "description", :default => ""
    t.string   "verb",        :limit => 24
  end
  
  rails generate access_logging:model
  
  class SecretsController < ApplicationController
    log_access_to :secret
    
    # restful actions: index, show, create, etc.
  end
  
  PUT '/sessions/new' # => John Smith signs in
  
  GET '/secrets' # => AccessLog.count += 1; John Smith viewed /secrets
  GET '/secrets/1' # => AccessLog.count += 1; John Smith viewed /secrets/1
  PUT '/secrets/1' # => AccessLog.count += 1; John Smith updated /secrets/1
  
  etc.
  
  AccessLog.find(2).secret # => <Secret id: 1>


TODO
----

* Add generator
* Log accesses to Redis first, then dump them into the SQL database later.