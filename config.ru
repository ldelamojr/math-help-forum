require "pry"
require "sinatra/reloader"
require "sinatra/base"
require "pg"
require "json"
require "rack"

require_relative "server"

use Rack::MethodOverride

run Forum::Server


