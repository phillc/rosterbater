path = Rails.root.join("config", "app_config.yml")
config = YAML.load(ERB.new(File.new(path).read).result)

APP_CONFIG = config["defaults"].deep_merge(config[Rails.env] || {}).with_indifferent_access
