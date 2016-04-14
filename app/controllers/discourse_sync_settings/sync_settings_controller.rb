load File.expand_path('../../../../lib/discourse_sync_settings/services/sync_settings_api_call_service.rb', __FILE__)

module DiscourseSyncSettings
  class SyncSettingsController < ::ApplicationController
    def sendSettings
      current_settings, unsync_settings = SyncSettingsInfo.perform
      SyncSettingsApiCallService.new.perform({current_settings: current_settings,
        unsync_settings: unsync_settings})

      obj = {data: "Current Site Settings Sent to The Consumer"}
      render json: obj
    end
  end
end
