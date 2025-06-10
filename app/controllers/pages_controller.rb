class PagesController < ApplicationController
  def public
    render json: { message: "public" }
  end

  def secured
    if authorized_role?("user")
      render json: { message: "secured" }
    else
      render json: { error: "Unauthorized" }, status: :unauthorized
    end
  end

  def admin
    if authorized_role?("admin")
      render json: { message: "admin" }
    else
      render json: { error: "Forbidden" }, status: :forbidden
    end
  end

  private

  def authorized_role?(role)
    token = request.env["keycloak.token"]
    roles = token&.dig("realm_access", "roles") || []
    puts "Checking role: #{role} in roles: #{roles}"
    roles.include?(role)
  end
end