# config/initializers/solid_queue.rb

Rails.application.configure do
  config.active_job.queue_adapter = :solid_queue
end
