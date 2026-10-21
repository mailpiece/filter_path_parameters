module FilterPathParameters
  # The Started line and the process_action event's path.
  module Request
    def filtered_path
      FilterPathParameters.filter_url(super)
    end
  end
end
