# app/middleware/keycloak/middleware.rb
require "jwt"
require "net/http"
require "json"

module Keycloak
  class Middleware
    def initialize(app)
      @app = app
      @realm = ENV.fetch("KEYCLOAK_REALM")
      @auth_server_url = ENV.fetch("KEYCLOAK_SITE")
      @jwks = fetch_jwks
    end

    def call(env)
      request = Rack::Request.new(env)
      path = request.path_info

      required_role = case path
                      when "/secured" then "user"
                      when "/admin"   then "admin"
                      else
                        return @app.call(env)
                      end

      auth_header = request.get_header("HTTP_AUTHORIZATION")
      unless auth_header&.start_with?("Bearer ")
        return unauthorized("Missing or invalid Authorization header")
      end

      token = auth_header.split.last
      payload = decode_token(token)
      return unauthorized("Invalid token") unless payload

      roles = payload.dig("realm_access", "roles") || []
      unless roles.include?(required_role)
        return forbidden("Insufficient role")
      end

      env["keycloak.token"] = payload
      @app.call(env)
    end

    private

    def fetch_jwks
      uri = URI("#{@auth_server_url}/realms/#{@realm}/protocol/openid-connect/certs")
      response = Net::HTTP.get(uri)
      keys     = JSON.parse(response)["keys"]
      JWT::JWK::Set.new(keys)
    rescue => e
      warn "Failed to fetch JWKS: #{e.message}"
      JWT::JWK::Set.new([])
    end

    def decode_token(token)
      @jwks.keys.each do |jwk|
        begin
          JWT.decode(token, jwk.public_key, true, algorithm: "RS256").first.tap { |p| return p }
        rescue JWT::DecodeError
          # try next key
        end
      end
      nil
    end

    def unauthorized(message)
      [401, { "Content-Type" => "application/json" }, [{ error: message }.to_json]]
    end

    def forbidden(message)
      [403, { "Content-Type" => "application/json" }, [{ error: message }.to_json]]
    end
  end
end
