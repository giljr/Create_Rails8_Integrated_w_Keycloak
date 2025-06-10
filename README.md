
# Rails 8 + Keycloak Integration: A Beginner’s Guide

Secure your Rails app with Keycloak authentication and role-based access control.

## 🔧 Prerequisites

- Ruby 3.2+
- Rails 8 (`gem install rails -pre`)
- Docker 27.3.1+
- `dotenv-rails` gem

## 🚀 Quick Setup

### 1. Clean Docker and Run Keycloak

```bash
docker rm -f $(docker ps -a -q)
docker system prune -a
docker run -d --name keycloak -e KEYCLOAK_ADMIN=admin -e 
```
```bash
KEYCLOAK_ADMIN_PASSWORD=admin -p 8080:8080 quay.io/keycloak/keycloak:25.0.2 start-dev
```
### 2. Configure Keycloak (http://localhost:8080)

    Create Realm: quickstart

    Create Client: test-cli

        Root URL: http://localhost:3000

        Disable Standard Flow, enable Direct Access Grants

    Create Roles: user, admin

    Create Users:

        alice / 123 → role: user

        admin / 123 → role: admin

### 3. Create Rails App

    rails new keycloak_demo
    cd keycloak_demo

### 4. Add Gems (Gemfile)
```bash
gem 'dotenv-rails', groups: [:development, :test]
gem 'jwt'
gem 'rack-cors'
gem 'rack-protection'
gem 'sinatra', require: false
```
```bash
bundle install
```
### 5. Configure .env
```bash
KEYCLOAK_REALM=quickstart
KEYCLOAK_SITE=http://localhost:8080
```
Add .env to .gitignore.

### 6. Add Middleware

`app/middleware/keycloak/middleware.rb `→ 🔗 See Full Middleware Code

Register it in `config/initializers/keycloak_middleware.rb`:
```bash
require Rails.root.join("app/middleware/keycloak/middleware")
Rails.application.config.middleware.use Keycloak::Middleware
```
### 7. Set Up Routes & Controller

    rails generate controller Pages public secured admin

config/routes.rb:
```bash
get "public", to: "pages#public"
get "secured", to: "pages#secured"
get "admin", to: "pages#admin"
```
`app/controllers/pages_controller.rb` → 🔗 See Full Controller Code

### 8. Token Usage (via Postman or curl)
Get Token (Alice)
```bash
POST http://localhost:8080/realms/quickstart/protocol/openid-connect/token
    client_id=test-cli
    username=alice
    password=123
    grant_type=password
```
Use Token
```bash
GET http://localhost:3000/secured
Authorization: Bearer <access_token>
```
Admin Access
```bash
GET http://localhost:3000/admin
Authorization: Bearer <admin_access_token>
```
### 9. Run the App

    bin/dev

✅ Endpoints Summary
Endpoint	Role Required	Notes
```bash
/public	None	Public access
/secured	user	Bearer token
/admin	admin	Bearer token
```
    Made with ❤️ by J3


Let me know if you want me to include the full middleware or controller code in collapsible s
## License

[MIT](https://choosealicense.com/licenses/mit/)

