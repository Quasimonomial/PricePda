Vetpda.Models.Product = Backbone.Model.extend({
	urlRoot: "/api/products", 
	// initialize: function () {
	//     Backbone.Model.prototype.initialize.apply(this, arguments);

	//  }
	getHistoricalCompanyPrices: function(callback){
		var that = this;
		console.log("This is callback")
		console.log(callback);
		var historicals = $.ajax({
			url: "/api/products/" + that.id + "/historical_prices",
			method: "GET",
  			dataType: 'json',
			success: function(){
				console.log("test");
				console.log(historicals);
				console.log(JSON.parse(historicals.responseText));
				responseObject = JSON.parse(historicals.responseText);
				that.set("historicalPrices", responseObject);
				console.log(that.get("historicalPrices"))
				that.fetch();
				// console.log(that)
			}
		});

	}
});