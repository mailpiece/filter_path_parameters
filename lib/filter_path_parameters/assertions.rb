module FilterPathParameters
  module Assertions
    def assert_path_filtered(path, secret)
      filtered = FilterPathParameters.filter_path(path)

      refute_includes filtered, secret, "Expected #{path.inspect} to be filtered, got #{filtered.inspect}"
    end
  end
end
