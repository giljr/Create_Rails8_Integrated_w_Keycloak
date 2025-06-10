# config/initializers/keycloak_middleware.rb
require Rails.root.join("app/middleware/keycloak/middleware")

Rails.application.config.middleware.use Keycloak::Middleware
