require_relative "test_helper"

class FilterPathParameters::ErrorMessagesTest < FilterPathParameters::TestCase
  include Rails.application.routes.url_helpers

  def test_a_url_generation_error_is_filtered
    error = assert_raises(ActionController::UrlGenerationError) do
      mailbox_forwarding_confirmation_path(nil, "t0k3n")
    end

    assert_includes error.message, %(forwarding_token: "[FILTERED]")
    assert_includes error.message, "missing required keys: [:mailbox_id]"
    refute_includes error.message, "t0k3n"
  end

  def test_an_undeclared_name_is_kept_in_a_url_generation_error
    error = assert_raises(ActionController::UrlGenerationError) { board_path(nil, filter: "x") }

    assert_includes error.message, %(filter: "x")
  end
end
