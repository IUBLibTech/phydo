module Phydo
  def config
    @config ||= config_yaml.with_indifferent_access
  end

private

  def config_yaml
    load_yaml File.read('/run/secrets/phydo_config')
  rescue Errno::ENOENT
    load_yaml File.read(File.join(Rails.root, 'docker.secrets.sample'))
  end

  def load_yaml(str)
    YAML.safe_load(ERB.new(str).result, [Symbol], [], true)[Rails.env]
  end

  module_function :config, :config_yaml, :load_yaml
end
