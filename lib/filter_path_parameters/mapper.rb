module FilterPathParameters
  module Mapper
    def filter_path_parameters(*names)
      drawn = @set.routes.size
      yield
      FilterPathParameters.declare(@set, @set.routes.drop(drawn), names.map(&:to_s))
    end
  end
end
