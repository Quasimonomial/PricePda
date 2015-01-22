Vetpda.Models.Product = Backbone.Model.extend({
	urlRoot: "/api/products", 
	initialize: function () {
	    Backbone.Model.prototype.initialize.apply(this, arguments);
	    // this.on("change", function (model, options) {
	    // if (options && options.save === false) return;
	    //   model.save();
	    // });
	 }
});