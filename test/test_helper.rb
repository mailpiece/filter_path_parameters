$LOAD_PATH.unshift File.expand_path("../lib", __dir__)

ENV["RAILS_ENV"] = "test"

require "minitest/autorun"
require "rails"
require "action_controller/railtie"
require "filter_path_parameters"

LOG = StringIO.new

class TestApp < Rails::Application
  config.root = __dir__
  config.eager_load = false
  config.logger = ActiveSupport::Logger.new(LOG)
  config.log_level = :debug
  config.hosts.clear
  config.secret_key_base = "a" * 64
  config.cache_store = :null_store
  config.filter_parameters = [ :password, :code ]
end

TestApp.initialize!

FilterPathParameters.prefix = /\A(\/\d{6,})/

class JoinCodesController < ActionController::Base
  def show
    render plain: "#{request.path} #{request.fullpath} #{request.original_url}"
  end
end

class ConfirmationsController < ActionController::Base
  def show
    render plain: params[:forwarding_token]
  end
end

class FilesController < ActionController::Base
  def show
    render plain: params[:path]
  end
end

class BoardsController < ActionController::Base
  def show
    render plain: params[:id]
  end
end

class RedirectsController < ActionController::Base
  def show
    redirect_to join_path("k7m2x9qp4", script_name: "/800966886", x: 1)
  end
end

def draw_routes
  Rails.application.routes.draw do
    filter_path_parameters :code do
      get "join/:code", to: "join_codes#show", as: :join
    end

    filter_path_parameters :token, :forwarding_token do
      resources :mailboxes, only: [] do
        resources :forwardings, param: :token, only: :create do
          resource :confirmation, only: :show
        end
      end
    end

    filter_path_parameters :path do
      get "files/*path", to: "files#show"
    end

    get "boards/:id", to: "boards#show", as: :board
    get "redirect", to: "redirects#show"
  end
end

draw_routes

module FilterPathParameters
  class TestCase < Minitest::Test
    private
      def filter(path)
        FilterPathParameters.filter_path(path)
      end
  end

  class IntegrationTestCase < ActionDispatch::IntegrationTest
    private
      def logged
        from = LOG.string.length
        yield
        LOG.string[from..]
      end
  end
end
