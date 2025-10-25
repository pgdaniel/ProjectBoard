# CORS is handled by Caddy reverse proxy in production
# In development, allow all origins for local testing
if Rails.env.development?
  Rails.application.config.middleware.insert_before 0, Rack::Cors do
    allow do
      origins '*'
      resource '*', headers: :any, methods: %i[get post put patch delete options]
    end
  end
end
