Vetpda.Views.RootIndex = Backbone.View.extend({
	template: JST['root/index'],

	initialize: function(options){
		var that = this;
		// console.log("Initializing Root View");
		this.companyCollection = options.companies;
		this.currentUser = options.user;
		this.listenTo(this.companyCollection, 'sync', this.render);
		this.listenTo(this.collection, 'sync', this.render);
		this.listenTo(this.currentUser, 'sync', this.render);
		$.ajax({
			url: "/api/products/distinct_categories",
			method: "Get",
  			dataType: 'json',
  			success: function(response){
				console.log("Categories fetched");
				that.categoriesArray = response
				that.render();
			}
		});
		
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
		'change .tableFilter' : 'renderTable',
		'focusout #percentInputFeild': 'updateUserModel',
		'change #comparisonCompany' : 'updateUserModel',
		'click .emailSelf': 'emailSelf',
		'submit .uploadUserPrices' : 'uploadUserPrices'
	},

	// handleTableFilters: function(event){
	// 	console.log("handling table")
	// 	var checkbox = event.target;
	// 	var limit = 3;

	// 	console.log(checkbox)
	// 	console.log(checkbox.siblings)
	// 	if(checkbox.siblings(':checked').length >= limit) {
	// 	   this.checked = false;
	// 	}

	// 	this.renderTable();
	// },

	uploadUserPrices: function(event){
		that = this;
		event.preventDefault();
		console.log("importing file")
		var attrs = $(event.target);
		$.ajax({
			url: "excel/upload_user_prices",
			method: "POST",
  			iframe: true,
  			files: $(event.target).find("#userPricesSheet"),
 			success: function(){
 				that.collection.fetch();
				console.log("Ajax succeeded");
			}
		});
	},


	emailSelf: function(){
		$.ajax({
			url: "/email/send_to_self",
			method: "POST",
  			dataType: 'json',
  			// complete: function(response, textStatus) {
   		// 	 return alert("Hey: " + textStatus);
  			// },
			success: function(){
				console.log("Ajax succeeded");
				alert("Email Sent Successfully");
			}
		});
	},


	updateUserModel:function(){
		// console.log("Event registered")
		// console.log( $('#comparisonCompany').val() );
		// console.log(this.currentUser)
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
		return $('input:checkbox.tableFilter:checked').map(function() {
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
			if (pricesArr.length === 0) {
				product.set({
				min: -1,
				max: -1,
				average: -1
			});
			}

			if(typeof currentUser.get("price_range_percentage") !== 'undefined'){
				product.set("priceRangePercentage", currentUser.get("price_range_percentage"));
			}
			var companiesOutOfRange = [];
			thatCompanyCollection.each(function(company){
				if(100 * (product.get("User") - product.get(company.get("name")))/product.get("User") >= product.get("priceRangePercentage")){
					companiesOutOfRange.push(company.get("name"));
				}
			});
			if(typeof currentUser !== 'undefined' && typeof product !== "undefined" && typeof thatCompanyCollection !== "undefined"){
				if (currentUser.get("comparison_company_id")) {
					if(100 * (product.get("User") - product.get(thatCompanyCollection.get(currentUser.get("comparison_company_id")).get("name")) )/product.get("User") >= product.get("priceRangePercentage") ){
						companiesOutOfRange.push("User");
					}
				}
			}
			product.set("companiesOutOfRange", companiesOutOfRange);

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
		var graphButtonCallback = function(product){
			console.log("Click Detected");
			Backbone.history.navigate("#/products/"+ product.id, {trigger: true});
		}

		var statColumns = [{name: "min",
		    label: "Low",
		    cell: "number", 
		  	editable: false
		  },{ name: "average",
		    label: "Avg",
		    cell: "number", 
		  	editable: false
		  },{ name: "max",
		    label: "High",
		    cell: "number", 
		  	editable: false
		  }];

		var columns = [//{
		  //   name: "id", // The key of the model attribute
		  //   label: "ID", // The name to display in the header
		  //   editable: false, // By default every cell in a column is editable, but *ID* shouldn't be
		  //   // Defines a cell type, and ID is displayed as an integer without the ',' separating 1000s.
		  //   cell: Backgrid.IntegerCell.extend({
		  //     orderSeparator: ''
		  //   })
		  // }, 
		  {
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
			label: this.currentUser.escape("abbreviation"),
			cell: "number",
			editable: true
		});
		columns.push({
			name: "View Graph",
			callback: graphButtonCallback,
			buttonText: "Graph!",
			cell: CustomButtonCell,
			editable: false
		});
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection,
  			row: StyledByDataRow
		});
		return grid;
	},

	renderTable: function(){
		// console.log("rendering the table")
		this.calculateProductStats();
		var grid = this.buildTable();
		this.$('#productsTable').html(grid.render().$el);

		var paginator = new Backgrid.Extension.Paginator({
		  windowSize: 20, // Default is 10

		  slideScale: 0.25, // Default is 0.5

		  goBackFirstOnSort: false, // Default is true

		  collection: this.collection
		});
		$('#productsTable').append(paginator.render().el);
		
		var productsFilter = new Backgrid.ClientSideFilterWithPickFilter({
			collection: this.collection,

			placeholder: "Search Products",
			// The model fields to search for matches
			fields: ['category', 'name', 'dosage', 'package'],
			// How long to wait after typing has stopped before searching can start
			wait: 250
		});
		productsFilter.setfilterColumn("category");
		$('input.categoryFilter').change(function(e) {
			productsFilter.setPickFilter($('input:checkbox.categoryFilter:checked').map(function() {
			    return this.value;
			}).get());
		}); 

		$("#productsTable").prepend(productsFilter.render().el);
	},

	render: function(){
		// console.log("Rendering View")
		var content = this.template({
			products: this.collection,
			companies: this.companyCollection,
			user: this.currentUser,
			categoriesArray: this.categoriesArray
		});

		this.$el.html(content);

		this.renderTable();

		return this;
	},

});