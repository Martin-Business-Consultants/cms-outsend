# frozen_string_literal: true

require "outsend/version"
require "outsend/engine"

# Outsend: the CMS's email (password resets, invitations, form notifications
# and confirmations, collection events) goes out through Outsend's relay with
# the API key saved in Settings › Outsend, instead of the SMTP_* environment.
module Outsend
  SETTING_KEY = "outsend"

  # Outsend's SMTP relay: plain auth, username "outsend", the API key as the
  # password (the core's production defaults, docs/install.md).
  RELAY = {address: "smtp.getoutsend.com", port: 2587, user_name: "outsend", authentication: :plain,
           enable_starttls_auto: true, open_timeout: 5, read_timeout: 5}.freeze

  # The saved API key, from the setting's encrypted `secrets`. Never shown.
  def self.api_key
    Setting.secret(SETTING_KEY, "api_key")
  end

  # Whether mail goes through Outsend now: the plugin is on and has a key.
  def self.active?
    Cms::Plugins.enabled?(:outsend) && api_key.present?
  end

  def self.smtp_settings
    RELAY.merge(password: api_key)
  end
end
