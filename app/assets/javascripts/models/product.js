Vetpda.Models.Product = Backbone.Model.extend({
	urlRoot: "/api/products", 
	initialize: function () {
	    Backbone.Model.prototype.initialize.apply(this, arguments);

	 }
	 
});