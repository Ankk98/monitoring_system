ALERT_EMAIL_IDS = YAML.load(ERB.new(File.read("#{Rails.root.to_s}/config/alert_email_ids.yml")).result)[Rails.env]

