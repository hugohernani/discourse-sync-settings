module DiscourseSyncSettings
  class SyncSettingsInfo
    class << self

      def perform
        current_settings = SiteSetting.current
        setting_keys = current_settings.keys
        unsync_settings = []
        if setting_keys.include?(:sync_settings_unsync_settings)
          unsync_settings = current_settings[:sync_settings_unsync_settings].
            split(/,/).map{ |s| s.squish.delete(' ').underscore.to_sym unless s.blank? }
        end
        [current_settings, unsync_settings]
      end

    end


  end
end
