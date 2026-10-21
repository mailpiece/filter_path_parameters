module FilterPathParameters
  # "No route matches [GET] "/join/abc/xmlrpc.php"" is raised with the raw path and logged as is,
  # so the path is filtered in the message itself, where every logger and error reporter reads it.
  module RoutingError
    QUOTED = /"([^"]*)"/

    def initialize(message, ...)
      super(message.gsub(QUOTED) { %("#{FilterPathParameters.filter_url($1)}") }, ...)
    end
  end
end
