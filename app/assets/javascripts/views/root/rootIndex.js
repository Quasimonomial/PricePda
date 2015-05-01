Vetpda.Views.RootIndex = Backbone.View.extend({
	template: JST['root/index'],

	initialize: function(options){
		var that = this;
		// console.log("Initializing Root View");
		this.companyCollection = options.companies;
		this.currentUser = options.user;
		this.listenTo(this.companyCollection, 'sync', this.render);
		this.listenTo(this.collection, 'sync', this.renderTable);
		// this.listenTo(this.collection, 'change', function(){console.log("Model Changed")});
		this.listenTo(this.collection, 'sync add remove', function(){console.log("Synch Occured")});
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
		'change .tableFilter' : 'handleTableFilters',
		'focusout #percentInputFeild': 'updateUserModel',
		'change #comparisonCompany' : 'updateUserModel',
		'click .emailSelf': 'emailSelf',
		'submit .uploadUserPrices' : 'uploadUserPrices',
		'click .selectAllCategories' : 'selectAllCategories',
		'click .deselectAllCategories' : 'deselectAllCategories'
	},

	selectAllCategories: function(){
		var $checkboxes = $(".filterCheckBoxes").find("input:checkbox");
		$checkboxes.each(function(){
			this.checked = true;
		});

		this.categoryFilter.setPickFilter($('input:checkbox.categoryFilter:checked').map(function() {
			return this.value;
		}).get());

	},
	
	deselectAllCategories: function(){
		var $checkboxes = $(".filterCheckBoxes").find("input:checkbox");
		$checkboxes.each(function(){
			this.checked = false;
		});

		this.categoryFilter.setPickFilter($('input:checkbox.categoryFilter:checked').map(function() {
			return this.value;
		}).get());
	},


	activeCompanies: function(){
		return $('input:checkbox.tableFilter:checked').map(function() {
		    return this.value;
		}).get();
	},
	
	buildTable: function(){
		var that = this;
		var graphButtonCallback = function(product){
			console.log("Click Detected");
			var productView = new Vetpda.Views.ProductShow({
				model: product,
				collection: that.companyCollection,
				user: that.currentUser
			});

			vex.open({
			  contentClassName: "graphVexContent",

			  content: productView.render().$el,
			  afterOpen: function($vexContent) {
			    return $vexContent.append($el);
			  },
			  afterClose: function() {
			    return console.log('vexClose');
			  }
			});
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

		var columns = [//{ ID COLUMN CAN BE ADDED FOR DEBUGGING PURPOSES BUT USERS DONT NEED TO SEE IT
		  //   name: "id", 
		  //   label: "ID", 
		  //   editable: false, 
		  //   cell: Backgrid.IntegerCell.extend({
		  //     orderSeparator: ''
		  //   })
		  // }, 
		  {
		    name: "category",
		    label: "Category",
		    cell: "string", 
		  	editable: false
		  }, {
		    name: "name",
		    label: "Product",
		    cell: "string", 
		    editable: false
		  }, {
		    name: "dosage",
		    label: "Dosage",
		    cell: "string",
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
			name: "User",
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


	calculateProductStats: function(){
		// console.log(this.collection.fullCollection)
		var activeCompanies = this.activeCompanies();
		var currentUser = this.currentUser
		var thatCompanyCollection = this.companyCollection
		this.collection.fullCollection.each(function(product){
			var pricesArr = [];
			var pricesArrSum = 0;
			for(var i = 0; i < activeCompanies.length; i++){
				if(isNaN( product.get(activeCompanies[i]) )){
					continue;
				}
				if(product.get(activeCompanies[i]) <= 0){
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
				min: null,
				max: null,
				average: null
			});
			}

			if(typeof currentUser.get("price_range_percentage") !== 'undefined'){
				product.set("priceRangePercentage", currentUser.get("price_range_percentage"));
			}
			var companiesOutOfRange = [];
			thatCompanyCollection.each(function(company){
				if(product.get(company.get("name")) > 0){
					if(100 * (product.get("User") - product.get(company.get("name")))/product.get("User") >= product.get("priceRangePercentage")){
						companiesOutOfRange.push(company.get("name"));
					}
				}
			});
			if(typeof currentUser !== 'undefined' && typeof product !== "undefined" && thatCompanyCollection.length > 0){
				if(currentUser.get("comparison_company_id")) {
					if(100 * (product.get("User") - product.get(thatCompanyCollection.get(currentUser.get("comparison_company_id")).get("name")) )/product.get("User") >= product.get("priceRangePercentage") ){						
						if(product.get(thatCompanyCollection.get(currentUser.get("comparison_company_id")).get("name")) > 0){
						companiesOutOfRange.push("User");
						}
					}
				}
			}
			product.set("companiesOutOfRange", companiesOutOfRange);

		});
	},

	comparisonCompany: function(){
		return $('select#comparisonCompany').val();
	},

	createCompanyCells: function(){
		var companyCells = []

		var checkedCompanies =  this.activeCompanies()

		for(var i = 0; i < checkedCompanies.length; i++){
			companyCells.push({
				name: checkedCompanies[i],
				label: checkedCompanies[i],
				editable: false,
				cell: "number" 
			})
		}

		return companyCells;
	},

	emailSelf: function(){
		$.ajax({
			url: "/email/send_to_self",
			method: "POST",
  			dataType: 'json',

			success: function(){
				console.log("Ajax succeeded");
				alert("Email Sent Successfully");
			}
		});
	},

	handleTableFilters: function(event){
		var limit = 3;
		var $checkboxes = $(".companiesCheckBoxes").find("input:checkbox");
		var numCheckBoxes = $checkboxes.filter(":checked").length;

		if(numCheckBoxes >= limit){
			$checkboxes.not(":checked").attr("disabled","disabled");
		} else {
			$checkboxes.removeAttr("disabled");
			var currentComparisonCompany = this.companyCollection.get(this.currentUser.get("comparison_company_id")).get("name")
			$checkboxes.filter(function(){return this.value == currentComparisonCompany}).attr("disabled","disabled");
		}

		var checkboxesSelected = $(".companiesCheckBoxes").find("input:checkbox").filter(":checked").map(function(i, el) {
    		return $(el).val();
		});

		var checkboxValues = [];
		for(var i = 0; i < numCheckBoxes; i++ ){
			checkboxValues[i] = checkboxesSelected[i] 
		}

		console.log(checkboxValues);

		Cookie.set("selectedCompanies=", checkboxValues.join(), 480, '/', false, false);// = "selectedCompanies="+ checkboxValues + "; path=/;";

		this.renderTable();
	},

	saveAllProducts: function(){
		//also saves our user
		console.log("saving")
		this.updateUserModel();
		
		var userPriceData = {}

		this.collection.fullCollection.each(function(product){
			userPriceData[product.id] = product.get("User");
		});
		
		var userPriceDataFull = {'prices': userPriceData}		

		$.ajax({
			url: "/api/products/mass_user_prices",
			method: "POST",
			data: userPriceDataFull,
  			success: function(){
 				console.log("User Saved Price changes");
			}
		});
		this.currentUser.save();
	},

	updateUserModel:function(event){
		console.log("updating percentage")
		if(typeof event !== "undefined"){
			event.preventDefault();
		}
		if(this.currentUser.get("comparison_company_id")){
			var currentComparisonCompany = this.companyCollection.get(this.currentUser.get("comparison_company_id")).get("name")
			$(".companiesCheckBoxes").find("input:checkbox").filter(function(){return this.value == currentComparisonCompany}).removeAttr("disabled");
			$(".companiesCheckBoxes").find("input:checkbox").filter(function(){return this.value == currentComparisonCompany}).prop('checked', false);
		}

		var userPercent = $('#percentInputFeild')[0].value;
		this.currentUser.set("price_range_percentage", userPercent);
		this.currentUser.set("comparison_company_id", $('#comparisonCompany').val());
		if(this.currentUser.get("comparison_company_id")){
			currentComparisonCompany = this.companyCollection.get(this.currentUser.get("comparison_company_id")).get("name")
			$(".companiesCheckBoxes").find("input:checkbox").filter(function(){return this.value == currentComparisonCompany}).prop('checked', true);
		}
		this.handleTableFilters();
	},
	
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

	renderTable: function(){
		this.calculateProductStats();
		var grid = this.buildTable();
		this.$('#productsTable').html(grid.render().$el);

		var paginator = new Backgrid.Extension.Paginator({
		  windowSize: 20,

		  slideScale: 0.25, 

		  goBackFirstOnSort: false, 

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
		if(Cookie.get("pricesEnteredFilter") != null){
			productsFilter.pricesEnteredFilter = Cookie.get("pricesEnteredFilter") === "true";
		}


		productsFilter.setfilterColumn("category");
		$('input.categoryFilter').change(function(e) {
			var categoriesSelected = $('input:checkbox.categoryFilter:checked').map(function() {
			    return this.value;
			}).get();

			Cookie.set("categoriesSelected", categoriesSelected, 480, '/');
			productsFilter.setPickFilter(categoriesSelected);
		});
		$('input.pricedToggle').change(function(e){
			productsFilter.togglePricesEnteredFilter();
			Cookie.set("pricesEnteredFilter", productsFilter.pricesEnteredFilter, 480, '/');
		});


		$("#productsTable").prepend(productsFilter.render().el);
		this.categoryFilter = productsFilter;



		if(Cookie.get("categoriesSelected") !== null){
			productsFilter.setPickFilter(Cookie.get("categoriesSelected").split(","));
		}


		productsFilter.search()
	},

	render: function(){
		var selectedCompanies = Cookie.get("selectedCompanies");
		
		if(selectedCompanies == null){
			selectedCompanies = []
		} else {
			selectedCompanies = selectedCompanies.slice( 1 ).split(",");
		}

		


		var content = this.template({
			products: this.collection,
			companies: this.companyCollection,
			user: this.currentUser,
			categoriesArray: this.categoriesArray,
			selectedCompanies: selectedCompanies
		});

		this.$el.html(content);

		this.renderTable();

		return this;
	},

});