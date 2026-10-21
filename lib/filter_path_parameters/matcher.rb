module FilterPathParameters
  # The leading segments of a route up to its last declared one. Rails squeezes repeated slashes
  # before routing, so //join/abc serves the join page and is matched here too.
  class Matcher
    SLASH = "/+"
    SEGMENT = "[^/]+"
    GLOB = ".*"

    def self.build(path, names)
      terminals = path.spec.select(&:terminal?)

      if last = terminals.rindex { |node| node.symbol? && names.include?(node.name) }
        new(terminals.first(last + 1), names)
      end
    end

    def initialize(terminals, names)
      @names = terminals.filter_map { |node| node.name if node.symbol? && names.include?(node.name) }
      @regexp = /\A#{terminals.map { |node| pattern(node, names) }.join}/i
    end

    def filter(path)
      if match = @regexp.match(path)
        path.dup.tap do |filtered|
          @names.reverse_each { |name| filtered[match.begin(name)...match.end(name)] = FILTERED }
        end
      else
        path
      end
    end

    private
      def pattern(node, names)
        case node.type
        when :SLASH   then SLASH
        when :DOT     then "\\."
        when :LITERAL then Regexp.escape(node.left)
        when :SYMBOL  then names.include?(node.name) ? "(?<#{node.name}>#{segment(node)})" : segment(node)
        end
      end

      def segment(node)
        node.left.start_with?("*") ? GLOB : SEGMENT
      end
  end
end
