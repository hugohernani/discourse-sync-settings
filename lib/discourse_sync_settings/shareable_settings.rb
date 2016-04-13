module ShareableSettings
  def self.included?(receiver)
    receiver.extend ClassMethods
  end

  module ClassMethods
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

    def shareable_settings(current_settings, current_changed_setting)
      shareable_settings = {
        site_settings: current_changed_setting,
        embeddable_hosts: embeddable_hosts(current_settings)
      }
      {"shareable_settings": shareable_settings}.to_json
    end
  end
end
