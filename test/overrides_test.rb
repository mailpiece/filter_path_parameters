require_relative "test_helper"

# Rails has no hook for any of these, so each is an override calling super. A Rails that
# renames or moves one leaves the credential in the log, and this is where that shows.
class FilterPathParameters::OverridesTest < FilterPathParameters::TestCase
  def test_filtered_path_is_still_rails
    method = ActionDispatch::Request.instance_method(:filtered_path)

    assert_equal FilterPathParameters::Request, method.owner
    assert_equal ActionDispatch::Http::FilterParameters, method.super_method.owner
  end

  def test_filtered_location_is_still_rails
    method = ActionDispatch::Response.instance_method(:filtered_location)

    assert_equal FilterPathParameters::Response, method.owner
    assert_equal ActionDispatch::Http::FilterRedirect, method.super_method.owner
  end

  def test_routing_error_is_still_built_with_a_message
    method = ActionController::RoutingError.instance_method(:initialize)

    assert_equal FilterPathParameters::RoutingError, method.owner
    assert_equal ActionController::RoutingError, method.super_method.owner
    assert_equal [ [ :req, :message ], [ :opt, :failures ] ], method.super_method.parameters
  end

  def test_clear_is_still_rails
    method = ActionDispatch::Routing::RouteSet.instance_method(:clear!)

    assert_equal FilterPathParameters::RouteSet, method.owner
    assert_equal ActionDispatch::Routing::RouteSet, method.super_method.owner
  end
end
