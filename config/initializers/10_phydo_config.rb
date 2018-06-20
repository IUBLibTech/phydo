module Phydo
  def config
    @config ||= config_yaml.with_indifferent_access
  end

private

  def config_yaml
    YAML.safe_load(ERB.new(File.read('/run/secrets/phydo_config')).result, [Symbol], [], true)[Rails.env]
  end

  module_function :config, :config_yaml
end
