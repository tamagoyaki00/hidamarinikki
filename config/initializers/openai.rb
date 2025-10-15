OpenAI.configure do |config|
  config.access_token = ENV.fetch("OPENAI_ACCESS_TOKEN")
  config.organization_id = ENV.fetch("OPENAI_ORGANIZATION_ID", nil) # Optional
  config.log_errors = true # Optional, but recommended for development
end
