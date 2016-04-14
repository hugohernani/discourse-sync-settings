load File.expand_path('../services/sync_settings_api_call.rb', __FILE__)

require_dependency "jobs/base"
module ::Jobs
  module DiscourseSyncSettings
    class SyncSettingsApiCallJob < Jobs::Base
      def execute(args)
        SyncSettingsApiCallService.new.perform(args)
      end
    end
  end
end
