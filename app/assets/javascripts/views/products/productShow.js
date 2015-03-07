Vetpda.Views.ProductShow = Backbone.View.extend({
	template: JST['products/show'],

	initialize: function(){
		console.log("initializing Products Edit view");
		this.listenTo(this.model, 'sync', this.render)
		this.model.getHistoricalCompanyPrices(this.render)
	},

	render: function(){
		console.log("The Model")
		console.log(this.model)
		var content = this.template({
			product: this.model
		});

		this.$el.html(content);
		
		return this;
	}

});