Vetpda.Views.ProductShow = Backbone.View.extend({
	template: JST['products/show'],

	initialize: function(){
		console.log("initializing Products Edit view");
		this.listenTo(this.model, 'sync', this.drawGoogleGraph);
		this.listenTo(this.model, 'sync', this.drawGoogleGraph);
		this.listenTo(this.collection, 'sync', this.render);
		this.listenTo(this.collection, 'sync', this.render);
		this.model.getHistoricalCompanyPrices(this.render);
		
		google.setOnLoadCallback(this.drawGoogleGraph);
	},

	drawGoogleGraph: function(){
		console.log("drawing graph")

		if(!this.model.get("historicalPrices")){
			return
		}
		historicals = this.model.get("historicalPrices")

		var historical_data = [['Month']];
		this.collection.each(function (company) {
			historical_data[0].push(company.get("name"));
		});
		// historical_data[0].push("Your Price")

		for(year in historicals){
			for(month in historicals[year]){
				var month_data = [month + "" + year];
				this.collection.each( function(company) {
					month_data.push(Number(historicals[year][month][company.get("name")]));
				})
				// month_data.push()
				console.log(month_data)
				historical_data.push(month_data);
			}
		}

		var data = google.visualization.arrayToDataTable(historical_data)

		// var data = google.visualization.arrayToDataTable([
		// 	['Month', 'Bolivia', 'Ecuador', 'Madagascar', 'Papua New Guinea', 'Rwanda', 'Average'],
		// 	['2004/05',  165,      938,         522,             998,           450,      614.6],
		// 	['2005/06',  135,      1120,        599,             1268,          288,      682],
		// 	['2006/07',  157,      1167,        587,             807,           397,      623],
		// 	['2007/08',  139,      1110,        615,             968,           215,      609.4],
		// 	['2008/09',  136,      691,         629,             1026,          366,      569.6]
		// ]);

		var options = {
			title : 'Historical Price of this Product over time',
			vAxis: {title: "Price in $", minValue: 0},
			hAxis: {title: "Month"},
			seriesType: "bars",
			series: {5: {type: "line"}}
		};

		var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));
		console.log("chart is")
		console.log(data)
		console.log(chart)
		chart.draw(data, options);

	},

	render: function(){

		var content = this.template({
			product: this.model,
			companies: this.collection
		});

		this.$el.html(content);
		
		return this;
	}

});