Pricepda.Models.Company = Backbone.Model.extend({
	urlRoot: "/api/companies",

	enabledString: function(){
		if (this.get("enabled") === true){
			return "Enabled";
		} else {
			return "Disabled";
		}
	},

  enabledToggleString: function(){
    //this gets us the opposite, as this is the command we get in the companies table
    if (this.get("enabled") === true){
      return "Disable";
    } else {
      return "Enable";
    }
  },

  toggleEnabled: function(){
    if (this.get("enabled") === true){
      this.set("enabled", false);
    } else {
      this.set("enabled", true);
    }
  }
});