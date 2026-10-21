module FilterPathParameters
  # The Redirected line.
  module Response
    def filtered_location
      FilterPathParameters.filter_url(super)
    end
  end
end
