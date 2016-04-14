# name: site-settings-sync-provider
# about: Plugin for syncronizing settings through discourse instances
# version: 0.0.1
# authors: Quezmedia

enabled_site_setting :sync_settings_enabled

# load the engine
load File.expand_path('../lib/discourse_sync_settings/engine.rb', __FILE__)

# Admin Routes
add_admin_route 'sync_settings.title', 'sync-settings'

# Appending Admin Routes
Discourse::Application.routes.append do
  # calling the default index action
  get '/admin/plugins/sync-settings' => 'admin/plugins#index'
  mount ::DiscourseSyncSettings::Engine, at: '/sync-settings'
end
