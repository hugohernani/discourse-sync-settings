# name: site-settings-sync-provider
# about: Plugin for syncronizing settings through discourse instances
# version: 0.0.1
# authors: Quezmedia

enabled_site_setting :sync_settings_enabled

# load the engine
load File.expand_path('../lib/discourse_sync_settings/engine.rb', __FILE__)
load File.expand_path('../lib/discourse_sync_settings/shareable_settings.rb', __FILE__)

after_initialize do
  require_dependency "jobs/base"
  module ::Jobs
    class SyncSettingsApiCall < Jobs::Base
      include ShareableSettings

      def execute(args)
        current_settings = args[:current_settings]
        setting_keys = current_settings.keys
        unsync_settings = args[:unsync_settings]
        if !sync_settings_names.include?(site_setting.name.to_sym) && !unsync_settings.include?(site_setting.name.to_sym)
          production_host = setting_keys.include?(:sync_settings_production_host) ? current_settings[:sync_settings_production_host] : nil
          production_api_key = setting_keys.include?(:sync_settings_production_api_key) ? current_settings[:sync_settings_production_api_key] : nil
          production_admin_username = setting_keys.include?(:sync_settings_production_admin_username) ? current_settings[:sync_settings_production_admin_username] : nil

          if production_host && production_api_key && production_admin_username && production_host != Discourse.base_url

            api_url = "#{production_host}/sync_settings/retrieve_discourse_settings.json?api_key=#{production_api_key}&api_username=#{production_admin_username}"
            uri = URI.parse(api_url)
            http = Net::HTTP.new(uri.host, uri.port)
            http.use_ssl = true if uri.scheme == 'https'

            request = Net::HTTP::Post.new(uri.path+"?"+uri.query)
            request.add_field('Content-Type', 'application/json')

            current_changed_setting = Hash.new
            current_changed_setting[args[:site_setting_name]] = args[:site_setting_value]

            request.body = shareable_settings(current_settings, current_changed_setting)

            case response
            when Net::HTTPSuccess
              Rails.logger.info("SiteSetting updated on #{uri.host}.")
            else
              Rails.logger.error("#{uri.host}: #{response.code} - #{response.message}")
            end
          end
        end
      end
    end
  end

  DiscourseEvent.on(:site_setting_saved) do |site_setting|
    current_settings = SiteSetting.current
    setting_keys = current_settings.keys
    unsync_settings = []
    if setting_keys.include?(:sync_settings_unsync_settings)
      unsync_settings = current_settings[:sync_settings_unsync_settings].split(/,/).map{ |s| s.strip.downcase.to_sym }
    end
    Jobs.enqueue(:sync_settings_api_call,
      {
        current_settings: current_settings,
        unsync_settings: unsync_settings,
        site_setting_name: site_setting.name, site_setting_value: site_setting.value
      }
    )
  end
end
