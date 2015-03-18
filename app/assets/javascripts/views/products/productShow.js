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

		var historical_data = [['Month', "Your Price"]];
		this.collection.each(function (company) {
			historical_data[0].push(company.get("name"));
		});
		// historical_data[0].push("Your Price")

		for(year in historicals){
			for(month in historicals[year]){
				var month_data = [month + "" + year];
				month_data.push(Number(historicals[year][month]["User"]));
				this.collection.each( function(company) {
					month_data.push(Number(historicals[year][month][company.get("name")]));
				})
				console.log(month_data)
				historical_data.push(month_data);
			}
		}

		var data = google.visualization.arrayToDataTable(historical_data)

		var options = {
			title : 'Historical Price of this Product over time',
			vAxis: {title: "Price in $", minValue: 0},
			hAxis: {title: "Month"},
			seriesType: "bars",
			series: { 0: {type: "line"}}
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