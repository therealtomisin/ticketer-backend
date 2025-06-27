Rails.application.config.middleware.insert_before 0, Rack::Cors do
  allow do
    origins "*"  # Or restrict to your Vue app origin

    resource "*",
      headers: :any,
      methods: [ :get, :post, :put, :patch, :delete, :options, :head ]
  end
end
