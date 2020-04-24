# frozen_string_literal: true

class Command
  attr_reader :config

  def initialize(config)
    @config = config
  end

  def build
    return base_command unless config

    "#{check_scope} #{base_command} #{fail_level} #{rubocop_config} #{excluded} #{force_exclusion}".strip.squeeze(" ")
  end

  private

  def base_command
    "rubocop --parallel -f json"
  end

  def check_scope
    return '' unless config["check_scope"] == "modified"
    "#{checkout_master}; git diff origin/master --name-only --diff-filter=AM | xargs"
  end

  def checkout_master
    'git fetch origin master'
  end

  def rubocop_config
    rubocop_config = config.fetch("rubocop_config_path", "")
    return "-c #{rubocop_config}" unless rubocop_config.empty?
  end

  def excluded
    excluded_cops = config.fetch("rubocop_excluded_cops", "")
    return "--except #{excluded_cops.join(' ')}" unless excluded_cops.empty?
  end

  def fail_level
    level = config.fetch("rubocop_fail_level", "")
    return "--fail-level #{level}" unless level.empty?
  end

  def force_exclusion
    force_exclusion = config.fetch("rubocop_force_exclusion", "").to_s
    return "--force-exclusion" unless force_exclusion.empty? || force_exclusion == "false"
  end
end
