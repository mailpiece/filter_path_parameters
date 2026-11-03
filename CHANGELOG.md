# Changelog

## Unreleased

- Initial release: `filter_path_parameters` in `config/routes.rb`, `FilterPathParameters.prefix`, `filter_path`, `filter_url` and the `Assertions` test helper.
- Filter a declared route's declared names in its request parameters, as the `Parameters` line and error reporters read them.
- Filter the values of declared names in the message of `ActionController::UrlGenerationError`.
