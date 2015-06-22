Pricepda.Views.ProductShow = Backbone.View.extend({
	template: JST['products/show'],

	initialize: function(options){
		console.log("initializing Products show view");
		this.currentUser = options.user;

		console.log(this.currentUser)

		this.listenTo(this.model, 'sync', this.drawGoogleGraph);
		this.listenTo(this.collection, 'sync', this.render);
		if(typeof this.currentUser !== 'undefined'){
			this.listenTo(this.currentUser, 'sync', this.render);
		}
		this.model.getHistoricalCompanyPrices(this.render);
		
		google.setOnLoadCallback(this.drawGoogleGraph);
	},

	events:{
		'change .graphFilter' : 'handleGraphFilters',
	},

	handleGraphFilters: function(event){
		console.log("Handling Filters");
		var limit = 3;
		var $checkboxes = $(".graphCheckBoxes").find("input:checkbox");
		var numCheckBoxes = $checkboxes.filter(":checked").length;
		console.log("numcheckboxes : " + numCheckBoxes)
		if(numCheckBoxes >= limit){
			console.log("bad");
			$checkboxes.not(":checked").attr("disabled","disabled");
		} else {
			console.log("good");
			$checkboxes.removeAttr("disabled");
		}

		this.drawGoogleGraph();
	},

	drawGoogleGraph: function(){
		console.log("drawing graph")

		if(typeof this.currentUser === 'undefined'){
			return
		}

		if(!this.model.get("historicalPrices")){
			return
		}

		var historicals = this.model.get("historicalPrices")

		this.defaultOrderArray = historicals["order_array"]
		this.currentOrderArray = historicals["order_array"]

		// var data = google.visualization.arrayToDataTable(getGraphDataSet)

		var options = {
			title : this.model.escape("category")  + '\n' + this.model.escape("name") + '\n' + this.model.escape("dosage") + '\n' + this.model.escape("package"),
			vAxis: {title: "Price in $", minValue: 0},
			hAxis: {title: "Month"},
			seriesType: "bars",
			series: { 0: {type: "line"}}
		};

		var chart = new google.visualization.ComboChart(document.getElementById('chart_div'));

		chart.draw(this.getGraphDataSet(), options);

		// Add our selection handler.
		google.visualization.events.addListener(chart, 'select', selectHandler);

		// The selection handler.
		// Loop through all items in the selection and concatenate
		// a single message from all of them.
		function selectHandler() {
		  var selection = chart.getSelection();
		  var chosenRow = null;
		  for (var i = 0; i < selection.length; i++) {
		    var item = selection[i];
			if (item.row != null){
				var chosenRow = item.row;
			}

		  }
		  if (chosenRow == null) {
		    return
		  }
		  // alert('You selected ' + that.currentOrderArray[chosenRow]);
		  expansion = that.currentOrderArray[chosenRow]
		  if(expansion[1] == 2013){
		  	return
		  }
		  switch (expansion[0]){
		  	case "Year":
		  		that.currentOrderArray = [["Quarter 1", expansion[1]], ["Quarter 2", expansion[1]], ["Quarter 3", expansion[1]], ["Quarter 4", expansion[1]]]
		  		chart.draw(that.getGraphDataSet(), options);
		  		break;
		  	case "Quarter 1":
		  		that.currentOrderArray = [["January", expansion[1]], ["February", expansion[1]], ["March", expansion[1]]]
		  		chart.draw(that.getGraphDataSet(), options);
		  		break;
		  	case "Quarter 2":
		  		that.currentOrderArray = [["April", expansion[1]], ["May", expansion[1]], ["June", expansion[1]]]
				chart.draw(that.getGraphDataSet(), options);
		  		break;
		  	case "Quarter 3":
		  		that.currentOrderArray = [["July", expansion[1]], ["August", expansion[1]], ["September", expansion[1]]]
		  		chart.draw(that.getGraphDataSet(), options);
		  		break;
		  	case "Quarter 4":
		  		that.currentOrderArray = [["October", expansion[1]], ["November", expansion[1]], ["December", expansion[1]]]
		  			chart.draw(that.getGraphDataSet(), options);
		  		break;
		  	default:
		  		that.currentOrderArray = that.defaultOrderArray;
		  		chart.draw(that.getGraphDataSet(), options);		  	
		  }

		}
	},

	//    month_names = [ "April", "May", "June", "July", "August", "September", "October", "November", "December", "Quarter 1", "Quarter 2", "Quarter 3", "Quarter 4", "Year"]


	getGraphDataSet: function(){
				var checkboxesSelected = $(".graphCheckBoxes").find("input:checkbox").filter(":checked").map(function(i, el) {
    		return $(el).val();
		});

		var checkboxValues = [];
		for(var i = 0; i < checkboxesSelected.length; i++ ){
			checkboxValues[i] = checkboxesSelected[i] 
		}

		numberSelectedCompanies = checkboxValues.length
		var historicals = this.model.get("historicalPrices")

		var historical_data = [['Month', this.currentUser.get("abbreviation")]];
		for(var i = 0; i < numberSelectedCompanies; i++){
			historical_data[0].push(checkboxValues[i])
		};
		

		for(i = 0; i < this.currentOrderArray.length; i++){
			var month = this.currentOrderArray[i][0]
			var year  = this.currentOrderArray[i][1]
			
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
		return google.visualization.arrayToDataTable(historical_data)
	},

	render: function(){		

		var selectedCompanies = Cookie.get("selectedCompanies");
		
		if(selectedCompanies == null){
			selectedCompanies = []
		} else {
			selectedCompanies = selectedCompanies.slice( 1 ).split(",");
		}


		var content = this.template({
			product: this.model,
			companies: this.collection,
			selectedCompanies: selectedCompanies
		});

		this.$el.html(content);
		
		return this;
	}

});