window.Vetpda = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    console.log('Hello from Backbone!');
    new Vetpda.Routers.VetRouter({$rootEl: $('#primary')});
  	vex.defaultOptions.className = "vex-theme-flat-attack"
    console.log("script initializing");
  	Backbone.history.start();

  }
};

$(document).ready(function(){
  Vetpda.initialize();
});
