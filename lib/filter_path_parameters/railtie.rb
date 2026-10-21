require "action_dispatch/http/request"
require "action_dispatch/http/response"

module FilterPathParameters
  class Railtie < Rails::Railtie
    initializer "filter_path_parameters" do
      ActionDispatch::Routing::Mapper.include Mapper
      ActionDispatch::Routing::RouteSet.prepend RouteSet
      ActionDispatch::Http::FilterParameters.prepend Request
      ActionDispatch::Http::FilterRedirect.prepend Response
      ActionController::RoutingError.prepend RoutingError
    end
  end
end
