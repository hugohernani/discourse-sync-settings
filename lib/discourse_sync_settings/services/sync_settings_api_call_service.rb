module DiscourseSyncSettings
  class SyncSettingsApiCallService

    def perform(args)
      current_settings = args[:current_settings]
      setting_keys = current_settings.keys
      unsync_settings = args[:unsync_settings]

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

        settings = current_settings.except(*[sync_settings_names,unsync_settings].flatten)

        request.body = shareable_settings(settings)

        response = http.request(request)

        case response
        when Net::HTTPSuccess
          Rails.logger.info("SiteSetting updated on #{uri.host}.")
        else
          Rails.logger.error("#{uri.host}: #{response.code} - #{response.message}")
        end
      end
    end

    private
    def sync_settings_names
      [:sync_settings_production_host,
        :sync_settings_production_api_key,
          :sync_settings_production_admin_username,
            :sync_settings_unsync_settings]
    end

    def embeddable_hosts(current_settings)
      if current_settings[:sync_settings_embeddable_comments_enabled].present? &&
        current_settings[:sync_settings_embeddable_comments_enabled] == true
        EmbeddableHost.select(:host, :category_id).map do |embeddable|
          {host: embeddable.host, category_id: embeddable.category_id}
        end
      else
        []
      end
    end

    def shareable_settings(current_settings)
      shareable_settings = {
        site_settings: current_settings,
        embeddable_hosts: embeddable_hosts(current_settings)
      }
      res = Hash.new
      res["shareable_settings"] = shareable_settings
      res.to_json
    end
  end
end
