# frozen_string_literal: true

require "rails_helper"

RSpec.describe "Settings › Outsend", type: :request do
  let(:admin) { create(:user) }

  it "is 404 while the plugin is off" do
    sign_in_as admin

    get settings_outsend_path

    expect(response).to have_http_status(:not_found)
  end

  context "while on" do
    before { switch_plugin :outsend, on: true }

    it "saves the API key encrypted and never shows it again" do
      sign_in_as admin

      patch settings_outsend_path, params: {settings: {api_key: "os_live_secret"}}
      expect(response).to redirect_to(settings_outsend_path)
      expect(Outsend.api_key).to eq("os_live_secret")
      expect(Setting.get(Outsend::SETTING_KEY).to_s).not_to include("os_live_secret")

      get settings_outsend_path
      expect(response.body).to include("Saved — leave blank to keep")
      expect(response.body).not_to include("os_live_secret")
    end

    it "keeps the saved key when the field is left blank, and removes it on request" do
      sign_in_as admin
      Setting.set_secret(Outsend::SETTING_KEY, "api_key" => "os_live_secret")

      patch settings_outsend_path, params: {settings: {api_key: ""}}
      expect(Outsend.api_key).to eq("os_live_secret")

      delete settings_outsend_path
      expect(Outsend.api_key).to be_nil
    end

    it "takes settings:write to change the key" do
      sign_in_as create(:user, admin: false, role: create(:role, permissions: %w[settings:read]))

      get settings_outsend_path
      expect(response).to have_http_status(:ok)

      patch settings_outsend_path, params: {settings: {api_key: "os_live_secret"}}

      expect(Outsend.api_key).to be_nil
    end
  end
end
