export default Ember.Controller.extend({
  settingsSent: false,
  settingsSynced: false,
  syncErrors: false,
  initErrors: '',
  parsedSyncErrors: '',
  result: '',

  init: function(){
    var self = this;
    var site_settings = Discourse.SiteSettings;
    if(!site_settings.sync_settings_enabled){
      self.set("syncErrors", true);
      self.set("initErrors", 'Enable sync_settings on Plugins first');
    };

    if(site_settings.sync_settings_production_admin_username.length == 0 ||
      site_settings.sync_settings_production_api_key.length == 0 ||
      site_settings.sync_settings_production_host.length == 0){
        self.set("syncErrors", true);
        self.set("initErrors", 'Check if all the required sync_settings were set before continuing with the syncronization');
      }
  },

  actions: {
    sendSettings() {
      var self = this;
      Discourse.ajax("/sync-settings/sendSettings", {
          type: 'POST'
        }).then(function(result){
          self.set('result', JSON.stringify(result));
        }).catch(function(error){
          console.log(error);
        });
    }
  }
});
