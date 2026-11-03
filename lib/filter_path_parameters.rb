require "filter_path_parameters/version"
require "filter_path_parameters/matcher"
require "filter_path_parameters/mapper"
require "filter_path_parameters/route_set"
require "filter_path_parameters/request"
require "filter_path_parameters/response"
require "filter_path_parameters/routing_error"
require "filter_path_parameters/assertions"
require "filter_path_parameters/railtie" if defined?(Rails::Railtie)

module FilterPathParameters
  FILTERED = "[FILTERED]"

  # The origin of a URL, if it has one, then its path: whatever is before the first `?` or `#`.
  URL = %r{\A(?<origin>[a-z][a-z0-9+.\-]*://[^/?#]*)?(?<path>[^?#]*)}i

  class << self
    attr_reader :prefix

    # Matched at the start of a path and kept unchanged, with the declared routes matched after it.
    def prefix=(regexp)
      @prefix = regexp && /\A(?:#{regexp})/
    end

    def filter_path(path)
      if path
        head = prefix && path[prefix] || ""
        head + matchers.inject(path.delete_prefix(head)) { |rest, matcher| matcher.filter(rest) }
      end
    end

    def filter_url(url)
      url&.sub(URL) { "#{$~[:origin]}#{filter_path($~[:path])}" }
    end

    def declare(route_set, routes, names)
      registry(route_set).concat routes.filter_map { |route| Matcher.build(route.path, names) }
      @matchers = @parameters = nil
    end

    def reset(route_set)
      registries.delete(route_set)
      @matchers = @parameters = nil
    end

    # The declared names of the routes drawn with this pattern, matching their parameters' keys.
    def parameters_for(pattern)
      parameters[pattern]
    end

    private
      def matchers
        @matchers ||= registries.values.flatten
      end

      def parameters
        @parameters ||= matchers.group_by(&:uri_pattern).transform_values do |matchers|
          /\A#{Regexp.union(matchers.flat_map(&:names).uniq)}\z/
        end
      end

      # One list per route set, so a redraw of one set keeps the others' declarations.
      def registry(route_set)
        registries[route_set] ||= []
      end

      def registries
        @registries ||= {}.compare_by_identity
      end
  end
end
