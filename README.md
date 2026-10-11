# Outsend

A plugin for the CMS (see `docs/plugins.md` in [LibrePublish CMS](https://github.com/Martin-Business-Consultants/cmsv2))
that sends the CMS's email through [Outsend](https://getoutsend.com) with an
API key you add in the admin, rather than in the install's environment.

Settings › Outsend has one field: the Outsend API key. Once it's saved, and
while the plugin is on, every email the CMS sends goes through Outsend's
relay with it: password resets, invitations, form notifications and
confirmations, collection events. The key is stored encrypted and never shown
again; leave the field blank to keep it, or remove it to stop.

Without a key, or with the plugin off, email goes out exactly as before (the
install's `SMTP_*` settings). Changes take effect on the next email, with no
restart.

Outsend only accepts mail from a domain your Outsend account has verified, so
the senders the CMS uses (Settings › General and Settings › Forms "From
address", or the install's `MAIL_FROM_ADDRESS`) should be on that domain.

## Install

Needs CMS 1.30 or newer.

In Settings › Plugins, under "Add a plugin", enter
`Martin-Business-Consultants/cms-outsend` and press Install. Or from the shell:

    bin/rails "plugins:install[https://github.com/Martin-Business-Consultants/cms-outsend,v0.1.0]"

or, for a Docker install, add the URL (with `#v0.1.0`) to `CMS_PLUGINS`. Then
switch it on in Settings › Plugins and add the key in Settings › Outsend.
Viewing the page takes `settings:read`, changing the key `settings:write`.

## Development

Its specs run inside the CMS, with the plugin in `plugins/`:

    ln -s ../../cms-plugins/outsend plugins/outsend
    bin/rspec plugins/outsend/spec

Licensed under the Functional Source License (FSL-1.1-MIT, `LICENSE.md`).
