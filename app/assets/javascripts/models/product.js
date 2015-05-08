Pricepda.Models.Product = Backbone.Model.extend({
	urlRoot: "/api/products", 

	getHistoricalCompanyPrices: function(callback){
		var that = this;

		var historicals = $.ajax({
			url: "/api/products/" + that.id + "/historical_prices",
			method: "GET",
  			dataType: 'json',
			success: function(){
				responseObject = JSON.parse(historicals.responseText);
				that.set("historicalPrices", responseObject);
				that.fetch();
			}
		});

	}
});