# frozen_string_literal: true

require "rails_helper"

RSpec.describe Outsend::Delivery do
  let!(:mail) { Mail.new(from: "forms@example.com", to: "owner@example.com", subject: "Hi", body: "Hello") }

  it "is every mailer's delivery method, with the install's own as the fallback" do
    expect(ActionMailer::Base.delivery_method).to eq(:outsend)
    expect(described_class.fallback.first).to eq(Mail::TestMailer)
  end

  it "sends through Outsend's relay with the saved key while the plugin is on" do
    switch_plugin :outsend, on: true
    Setting.set_secret(Outsend::SETTING_KEY, "api_key" => "os_live_secret")
    smtp = instance_double(Mail::SMTP, deliver!: true)
    expect(Mail::SMTP).to receive(:new)
      .with(hash_including(address: "smtp.getoutsend.com", port: 2587, user_name: "outsend", password: "os_live_secret"))
      .and_return(smtp)

    expect { described_class.new.deliver!(mail) }.not_to change(ActionMailer::Base.deliveries, :size)
    expect(smtp).to have_received(:deliver!).with(mail)
  end

  it "leaves mail to the install's own method without a key" do
    switch_plugin :outsend, on: true
    expect(Mail::SMTP).not_to receive(:new)

    expect { described_class.new.deliver!(mail) }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end

  it "leaves mail to the install's own method while the plugin is off, key or not" do
    switch_plugin :outsend, on: false
    Setting.set_secret(Outsend::SETTING_KEY, "api_key" => "os_live_secret")
    expect(Mail::SMTP).not_to receive(:new)

    expect { described_class.new.deliver!(mail) }.to change(ActionMailer::Base.deliveries, :size).by(1)
  end
end
