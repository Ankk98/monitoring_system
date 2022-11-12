Sidekiq.configure_server do |config|
  #config.redis = { url: 'redis://localhost:6379/1000', namespace: "monitoring_system_sidekiq_#{Rails.env}" }
end

Sidekiq.configure_client do |config|
  #config.redis = { url: 'redis://localhost:6379/1000', namespace: "monitoring_system_sidekiq_#{Rails.env}" }
end
