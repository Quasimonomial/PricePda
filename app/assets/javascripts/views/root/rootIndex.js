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
				collection: that.companyCollection
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
		var activeCompanies = this.activeCompanies();
		var currentUser = this.currentUser
		var thatCompanyCollection = this.companyCollection
		this.collection.each(function(product){
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
		}
		var checkboxesSelected = $(".companiesCheckBoxes").find("input:checkbox").filter(":checked").map(function(i, el) {
    		return $(el).val();
		});

		var checkboxValues = [];
		for(var i = 0; i < numCheckBoxes; i++ ){
			checkboxValues[i] = checkboxesSelected[i] 
		}

		console.log(checkboxValues);
		document.cookie = "selectedCompanies="+ checkboxValues + "; path=/;";

		this.renderTable();
	},

	saveAllProducts: function(){
		//also saves our user
		this.updateUserModel();

		this.collection.each(function(product){
			product.save();
		});
		this.currentUser.save();
	},

	updateUserModel:function(){
		var userPercent = $('#percentInputFeild')[0].value;
		this.currentUser.set("price_range_percentage", userPercent);
		this.currentUser.set("comparison_company_id", $('#comparisonCompany').val());
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
		productsFilter.setfilterColumn("category");
		$('input.categoryFilter').change(function(e) {
			productsFilter.setPickFilter($('input:checkbox.categoryFilter:checked').map(function() {
			    return this.value;
			}).get());
		});
		$('input.pricedToggle').change(function(e){
			productsFilter.togglePricesEnteredFilter();
		});

		$("#productsTable").prepend(productsFilter.render().el);
		this.categoryFilter = productsFilter;
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