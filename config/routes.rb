DiscourseSyncSettings::Engine.routes.draw do
  post '/sendSettings' => 'sync_settings#sendSettings'
end
