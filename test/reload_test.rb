require_relative "test_helper"

class FilterPathParameters::ReloadTest < FilterPathParameters::TestCase
  def teardown
    draw_routes
  end

  def test_a_redraw_replaces_the_declarations
    Rails.application.routes.draw do
      filter_path_parameters :transfer do
        get "transfers/:transfer", to: "transfers#show"
      end
    end

    assert_equal "/join/k7m2x9qp4", filter("/join/k7m2x9qp4")
    assert_equal "/transfers/[FILTERED]", filter("/transfers/abc")
  end

  def test_nested_declarations_accumulate
    Rails.application.routes.draw do
      filter_path_parameters :code do
        filter_path_parameters :token do
          get "join/:code/tokens/:token", to: "tokens#show"
        end
        get "join/:code", to: "join_codes#show"
      end
    end

    assert_equal "/join/[FILTERED]/tokens/[FILTERED]", filter("/join/abc/tokens/def")
    assert_equal "/join/[FILTERED]", filter("/join/abc")
  end
end
