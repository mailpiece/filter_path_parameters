module FilterPathParameters
  # "No route matches {action: "show", token: "abc", id: nil}" is raised with the values a route
  # helper was given, so the values of declared names are filtered in the message itself.
  module UrlGenerationError
    QUOTED = /"(?:[^"\\]|\\.)*"/

    def initialize(message, ...)
      if (names = FilterPathParameters.names).any?
        message = message.gsub(/(?<=[{ ])(#{Regexp.union(names)}): (?:#{QUOTED}|[^,}]*)/) { %(#{$1}: "#{FILTERED}") }
      end

      super(message, ...)
    end
  end
end
