Vetpda.Views.ProductShow = Backbone.View.extend({
	template: JST['products/show'],

	initialize: function(){
		console.log("initializing Products show view");
		this.listenTo(this.model, 'sync', this.drawGoogleGraph);
		this.listenTo(this.model, 'sync', this.drawGoogleGraph);
		this.listenTo(this.collection, 'sync', this.render);
		this.listenTo(this.collection, 'sync', this.render);
		this.model.getHistoricalCompanyPrices(this.render);
		
		google.setOnLoadCallback(this.drawGoogleGraph);
	},

	events:{
		'change .graphFilter' : 'handleGraphFilters',
	},

	handleGraphFilters: function(event){
		// var limit = 3;
		// var $checkboxes = $(".graphCheckBoxes").find("input:checkbox");
		// var numCheckBoxes = $checkboxes.filter(":checked").length;

		// if(numCheckBoxes >= limit){
		// 	$checkboxes.not(":checked").attr("disabled","disabled");
		// } else {
		// 	$checkboxes.removeAttr("disabled");
		// }

		this.drawGoogleGraph();
	},

	drawGoogleGraph: function(){
		console.log("drawing graph")

		var checkboxesSelected = $(".graphCheckBoxes").find("input:checkbox").filter(":checked").map(function(i, el) {
    		return $(el).val();
		});

		var checkboxValues = [];
		for(var i = 0; i < checkboxesSelected.length; i++ ){
			checkboxValues[i] = checkboxesSelected[i] 
		}

		numberSelectedCompanies = checkboxValues.length

		if(!this.model.get("historicalPrices")){
			return
		}
		var historicals = this.model.get("historicalPrices")

		console.log(historicals)

		var historical_data = [['Month', "Your Price"]];
		for(var i = 0; i < numberSelectedCompanies; i++){
			historical_data[0].push(checkboxValues[i])
		};
		

		for(i = 0; i < historicals["order_array"].length; i++){
			var month = historicals["order_array"][i][0]
			var year  = historicals["order_array"][i][1]
			
			var month_data = [month + " " + year];
			if(typeof historicals[year] === "undefined"){
				continue
			}
			if(typeof historicals[year][month] === "undefined"){
				continue
			}

			month_data.push(Number(historicals[year][month]["User"]));

			for(var j = 0; j < numberSelectedCompanies; j++ ){
				month_data.push(Number(historicals[year][month][checkboxValues[j]]));
			}

			historical_data.push(month_data);
		}

		var data = google.visualization.arrayToDataTable(historical_data)

		console.log(data)

		var options = {
			title : this.model.escape("category")  + '\n' + this.model.escape("name") + '\n' + this.model.escape("dosage") + '\n' + this.model.escape("package"),
			vAxis: {title: "Price in $", minValue: 0},
			hAxis: {title: "Month"},
			seriesType: "bars",
			series: { 0: {type: "line"}}
		};

		var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));

		chart.draw(data, options);

	},

	render: function(){
		function getCookie(cname) {
		    var name = cname + "=";
		    var ca = document.cookie.split(';');
		    for(var i=0; i<ca.length; i++) {
		        var c = ca[i];
		        while (c.charAt(0)==' ') c = c.substring(1);
		        if (c.indexOf(name) == 0) return c.substring(name.length, c.length);
		    }
		    return "";
		}
		var selectedCompanies = getCookie("selectedCompanies").split(',')

		var content = this.template({
			product: this.model,
			companies: this.collection,
			selectedCompanies: selectedCompanies
		});

		this.$el.html(content);
		
		return this;
	}

});