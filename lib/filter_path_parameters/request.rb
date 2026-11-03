module FilterPathParameters
  # The Started line and the process_action event's path, and on a declared route the
  # declared names in its parameters: the Parameters line and what error reporters read.
  module Request
    def filtered_path
      FilterPathParameters.filter_url(super)
    end

    def parameter_filter
      if names = FilterPathParameters.parameters_for(route_uri_pattern)
        parameter_filter_for Array(get_header("action_dispatch.parameter_filter")) + [ names ]
      else
        super
      end
    end
  end
end
