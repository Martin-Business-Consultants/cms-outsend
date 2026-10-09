# frozen_string_literal: true

module Outsend
  # An Action Mailer delivery method. While Outsend is active (the plugin is
  # on and has an API key) a message goes to Outsend's SMTP relay with that
  # key; otherwise to the install's own delivery method, untouched. Checked
  # per message, so saving or removing the key, or switching the plugin off,
  # takes effect without a restart.
  class Delivery
    class_attribute :fallback

    attr_reader :settings

    def initialize(settings = {})
      @settings = settings
    end

    def deliver!(mail)
      if Outsend.active?
        Mail::SMTP.new(Outsend.smtp_settings).deliver!(mail)
      else
        klass, fallback_settings = fallback || [Mail::SMTP, settings]
        klass.new(fallback_settings || {}).deliver!(mail)
      end
    end
  end
end
