require_relative "test_helper"

class FilterPathParameters::LoggingTest < FilterPathParameters::IntegrationTestCase
  def test_the_started_line_is_filtered
    output = logged { get "/800966886/join/k7m2x9qp4?password=hunter2&x=1" }

    assert_includes output, %(Started GET "/800966886/join/[FILTERED]?password=[FILTERED]&x=1")
    refute_includes output, "k7m2x9qp4"
  end

  def test_the_process_action_event_path_is_filtered
    paths = []
    callback = ->(event) { paths << event.payload[:path] }

    ActiveSupport::Notifications.subscribed(callback, "process_action.action_controller") do
      get "/join/k7m2x9qp4?x=1"
    end

    assert_equal [ "/join/[FILTERED]?x=1" ], paths
  end

  def test_the_redirected_line_is_filtered
    output = logged { get "/redirect" }

    assert_response :redirect
    assert_equal "http://www.example.com/800966886/join/k7m2x9qp4?x=1", response.location
    assert_includes output, "Redirected to http://www.example.com/800966886/join/[FILTERED]?x=1"
    refute_includes output, "k7m2x9qp4"
  end

  def test_a_routing_error_is_filtered
    output = logged { get "/join/k7m2x9qp4/xmlrpc.php" }

    assert_response :not_found
    assert_includes output, %(ActionController::RoutingError (No route matches [GET] "/join/[FILTERED]/xmlrpc.php"))
    refute_includes output, "k7m2x9qp4"
  end

  def test_repeated_slashes_route_and_are_filtered
    output = logged { get "//join/k7m2x9qp4" }

    assert_response :success
    assert_includes output, %(Started GET "//join/[FILTERED]")
    refute_includes output, "k7m2x9qp4"
  end

  def test_an_undeclared_route_is_logged_unchanged
    output = logged { get "/boards/42?x=1" }

    assert_includes output, %(Started GET "/boards/42?x=1")
  end

  def test_the_controller_sees_the_real_path
    get "/join/k7m2x9qp4?x=1"

    assert_equal "/join/k7m2x9qp4 /join/k7m2x9qp4?x=1 http://www.example.com/join/k7m2x9qp4?x=1", response.body
  end

  def test_a_nested_resource_routes_and_is_filtered
    output = logged { get "/mailboxes/42/forwardings/t0k3n/confirmation" }

    assert_equal "t0k3n", response.body
    assert_includes output, %(Started GET "/mailboxes/42/forwardings/[FILTERED]/confirmation")
  end
end
