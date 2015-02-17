Vetpda.Views.RootIndex = Backbone.View.extend({
	template: JST['root/index'],

	initialize: function(options){
		console.log("Initializing Root View");
		this.companyCollection = options.companies;
		this.currentUser = options.user;
		console.log(options.companies);
		// this.companyCollection.con('reset', this.render, this);
		this.listenTo(this.companyCollection, 'sync', this.render)
		this.listenTo(this.collection, 'sync', this.render);
		this.listenTo(this.currentUser, 'sync', this.render);
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
		'click .tableFilter' : 'renderTable',
		'focusout #percentInputFeild': 'updateUserModel',
		'change #comparisonCompany' : 'updateUserModel'
	},

	updateUserModel:function(){
		console.log("Event registered")
		console.log( $('#comparisonCompany').val() );
		console.log(this.currentUser)
		var userPercent = $('#percentInputFeild')[0].value;
		this.currentUser.set("price_range_percentage", userPercent);
		this.currentUser.set("comparison_company_id", $('#comparisonCompany').val());
	},

	saveAllProducts: function(){
		//also saves our user
		this.updateUserModel();

		this.collection.each(function(product){
			product.save();
		});
		this.currentUser.save();
	},

	activeCompanies: function(){
		return $('input:checkbox:checked').map(function() {
		    return this.value;
		}).get();
	},
	
	comparisonCompany: function(){
		return $('select#comparisonCompany').val();
	},

	calculateProductStats: function(){
		var activeCompanies = this.activeCompanies();
		var currentUser = this.currentUser
		var thatCompanyCollection = this.companyCollection
		this.collection.each(function(product){
			var pricesArr = [];
			pricesArrSum = 0;
			for(var i = 0; i < activeCompanies.length; i++){
				if(isNaN( product.get(activeCompanies[i]) )){
					continue;
				}
				pricesArr.push(product.get(activeCompanies[i]));
				pricesArrSum += product.get(activeCompanies[i]);
			}
			

			product.set({
				min: Math.min.apply(null, pricesArr),
				max: Math.max.apply(null, pricesArr),
				average: pricesArrSum/pricesArr.length,
			});
			if(typeof currentUser.get("price_range_percentage") !== 'undefined'){
				product.set("priceRangePercentage", currentUser.get("price_range_percentage"));

			}
			var companiesOutOfRange = [];
			thatCompanyCollection.each(function(company){
				//console.log(product.get("User"));
				if(100 * (product.get("User") - product.get(company.get("name")))/product.get("User") >= product.get("priceRangePercentage")){
					companiesOutOfRange.push(company.get("name"));
				}
			});
			product.set("companiesOutOfRange", companiesOutOfRange);
			//console.log(product);

		});
	},

	createCompanyCells: function(){
		var companyCells = []

		var checkedCompanies =  this.activeCompanies()

		for(var i = 0; i < checkedCompanies.length; i++){
			companyCells.push({
				name: checkedCompanies[i], //.toLowerCase(),
				label: checkedCompanies[i], //.toLowerCase(),
				editable: false,
				cell: "number" 
			})
		}

		return companyCells;
	},

	buildTable: function(){
		var statColumns = [{name: "min",
		    label: "Min",
		    cell: "number", 
		  	editable: false
		  },{ name: "average",
		    label: "Average",
		    cell: "number", 
		  	editable: false
		  },{ name: "max",
		    label: "Max",
		    cell: "number", 
		  	editable: false
		  }];

		var columns = [{
		    name: "id", // The key of the model attribute
		    label: "ID", // The name to display in the header
		    editable: false, // By default every cell in a column is editable, but *ID* shouldn't be
		    // Defines a cell type, and ID is displayed as an integer without the ',' separating 1000s.
		    cell: Backgrid.IntegerCell.extend({
		      orderSeparator: ''
		    })
		  }, {
		    name: "category",
		    label: "Category",
		    // The cell type can be a reference of a Backgrid.Cell subclass, any Backgrid.Cell subclass instances like *id* above, or a string
		    cell: "string", // This is converted to "StringCell" and a corresponding class in the Backgrid package namespace is looked up
		  	editable: false
		  }, {
		    name: "name",
		    label: "Product",
		    cell: "string", // An integer cell is a number cell that displays humanized integers
		    editable: false
		  }, {
		    name: "dosage",
		    label: "Dosage",
		    cell: "string", // A cell type for floating point value, defaults to have a precision 2 decimal numbers
		  	editable: false
		  }, {
		    name: "package",
		    label: "Package",
		    cell: "string",
		    editable: false
		}].concat(this.createCompanyCells());

		if (this.createCompanyCells().length > 0){
			columns = columns.concat(statColumns)
		}

	    columns.push({
			name: "User", //possibly get this to be the users username
			label: "Your Prices",
			cell: "number",
			editable: true
		});
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection,
  			row: StyledByDataRow
		});
		return grid;

	},

	renderTable: function(){
		console.log("rendering the table")
		this.calculateProductStats();
		var grid = this.buildTable();
		$('#productsTable').html(grid.render().el);
	},

	render: function(){
		console.log("Rendering View")
		var content = this.template({
			companies: this.companyCollection,
			user: this.currentUser
		});

		this.$el.html(content);

		this.renderTable();

		return this;
	},

});