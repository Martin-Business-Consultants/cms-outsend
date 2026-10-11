# frozen_string_literal: true

module Outsend
  # A CMS plugin (docs/plugins.md in the core). It owns no tables: the API
  # key is kept encrypted in the `outsend` Setting's secrets.
  class Engine < ::Rails::Engine
    initializer "outsend.routes" do |app|
      app.routes.append do
        namespace :settings do
          resource :outsend, only: [:show, :update, :destroy], controller: "outsend"
        end
      end
    end

    # Every mailer delivers through Outsend::Delivery, which uses Outsend
    # while the plugin is on with a key and the install's own delivery
    # method (SMTP_* in production, :test in specs…) otherwise. Settled after
    # the environment's config, so the install's method is the fallback.
    config.after_initialize do
      ActiveSupport.on_load(:action_mailer) do
        next if delivery_method == :outsend

        Outsend::Delivery.fallback = [delivery_methods.fetch(delivery_method), public_send(:"#{delivery_method}_settings")]
        add_delivery_method :outsend, Outsend::Delivery
        self.delivery_method = :outsend
      end
    end

    config.to_prepare do
      Cms::Plugins.register :outsend, name: "Outsend", version: Outsend::VERSION,
        author: "Martin Business Consultants", enabled_by_default: false, requires: ">= 1.30",
        homepage: "https://github.com/Martin-Business-Consultants/cms-outsend",
        description: "Send the CMS's email through Outsend: add your Outsend API key in Settings › Outsend."
      Cms::Plugins.settings :outsend, "Outsend", -> { settings_outsend_path },
        description: "The Outsend API key the CMS sends its email with.", capability: "settings:read",
        group: "Workspace", after: "Forms"
    end
  end
end
