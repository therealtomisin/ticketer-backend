Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins ENV.fetch("FRONTEND_URL"), ENV.fetch("ADMIN_URL_URL")

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
