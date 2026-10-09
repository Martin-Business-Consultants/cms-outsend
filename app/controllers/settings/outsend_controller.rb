# frozen_string_literal: true

# Settings › Outsend: the API key the CMS sends its email with. Stored in the
# `outsend` setting's encrypted secrets and never shown again once saved.
class Settings::OutsendController < Settings::BaseController
  include PluginGated
  plugin :outsend

  requires_capability "settings:read",  only: :show
  requires_capability "settings:write", only: [:update, :destroy]

  def show
    @key_saved = Outsend.api_key.present?
  end

  # A blank field keeps the saved key (the page never shows it).
  def update
    key = params.dig(:settings, :api_key).to_s.strip
    if key.present?
      Setting.set_secret(Outsend::SETTING_KEY, "api_key" => key)
      Event.record("settings.outsend_updated", fields: %w[api_key])
      redirect_to settings_outsend_path, notice: "Outsend API key saved. The CMS sends its email through Outsend."
    else
      redirect_to settings_outsend_path, notice: "Nothing changed"
    end
  end

  def destroy
    Setting.set_secret(Outsend::SETTING_KEY, "api_key" => nil)
    Event.record("settings.outsend_updated", fields: %w[api_key])
    redirect_to settings_outsend_path, notice: "Outsend API key removed. Email goes out as it did before."
  end
end
