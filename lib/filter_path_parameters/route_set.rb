module FilterPathParameters
  # Routes are cleared before every draw, in development on every reload, so the declarations
  # of a route set go with its routes.
  module RouteSet
    def clear!
      FilterPathParameters.reset(self)
      super
    end
  end
end
