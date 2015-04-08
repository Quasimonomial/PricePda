Vetpda.Views.ProductsIndex = Backbone.View.extend({
	template: JST['products/index'],

	initialize: function(options){
		var that = this;
		console.log("initializing products Index view");
		this.companyCollection = options.companies;
		this.user = options.user
		this.listenTo(this.user, 'sync', this.render)
		this.listenTo(this.companyCollection, 'sync', this.render)
		this.listenTo(this.collection, 'sync add remove', this.render)
		$.ajax({
			url: "/api/products/distinct_categories",
			method: "Get",
  			dataType: 'json',
  			success: function(response){
				console.log("Categories fetched");
				that.categoriesArray = response
				that.collection.fetch();
			}
		});
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
		'click .emailAll': 'emailAll',
		'submit .productAdd' : 'addProduct',
		'submit .uploadProducts' : 'uploadProductsFile',
		'submit .uploadCompanyPrices' : 'uploadCompanyPrices'
	},

	addProduct: function(event){
		event.preventDefault();

		var product = new Vetpda.Models.Product

		var attrs = $(event.target).serializeJSON();
		

		var success = function () {
	      this.collection.add(product, { merge: true });
	    }.bind(this)

	    function errors (model, response) {
	      $('.errors').empty();
	      response.responseJSON.forEach(function (el) {
	        var li = $('<li></li>');
	        li.html(el);
	        $('.errors').append(li);
	      }.bind(this));
	    }

	    product.save(attrs, {
	      success: success,
	      error: errors.bind(this)
	    });
	},

	buildTable: function(){
		var columns = [{
		    name: "id", 
		    label: "ID",
		    editable: false,
		    cell: Backgrid.IntegerCell.extend({
		      orderSeparator: ''
		    })
		  }, {
		    name: "category",
		    label: "Category",
		    cell: "string",
		  }, {
		    name: "name",
		    label: "Product",
		    cell: "string",
		  }, {
		    name: "dosage",
		    label: "Dosage",
		    cell: "string",
		  }, {
		    name: "package",
		    label: "Package",
		    cell: "string",
		  }].concat(this.createCompanyCells());
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection
		});
		return grid;
	},

	createCompanyCells: function(){
		var companyCells = []
		this.companyCollection.each( function(company) { 
			companyCells.push({
				name: company.get("name"), //.toLowerCase(),
				label: company.get("name"), //.toLowerCase(),
				editable: true,
				cell: "number" 
			})
		});

		return companyCells;
	},
		
	emailAll: function(){
		$.ajax({
			url: "/email/send_to_all",
			method: "POST",
  			dataType: 'json',
			success: function(){
				console.log("Ajac succeeded");
				alert("Emails Sent Successfully");
			}
		});
	},
	
	saveAllProducts: function(){
		console.log(this.collection);//.save();
		this.collection.each(function(product){
			product.save();
		});
	},

	uploadCompanyPrices: function(event){
		var that = this;
		event.preventDefault();
		console.log("Importing prices file")
		var attrs = $(event.target).serializeJSON();
		$.ajax({
			url: "excel/import_company_prices",
			method: "POST",
  			iframe: true,
  			files: $(event.target).find("#companyPricesSheet"),
  			// dataType: 'json',
  			data: attrs,
 			success: function(){
				console.log("Ajax succeeded");
				alert("Prices Uploaded Successfully")
 				that.collection.fetch();
			},
			error: function(){
				alert("Error Detected")
			}
		});
	},

	uploadProductsFile: function(event){
		var that = this;
		event.preventDefault();
		console.log("importing file")
		var attrs = $(event.target);
		$.ajax({
			url: "excel/import_products",
			method: "POST",
  			iframe: true,
  			files: $(event.target).find("#productsSheet"),
 			success: function(){
				alert("Uploads Succeeded");
 				that.collection.fetch();
			},
			error: function(){
				alert("Error Detected")
			}
		});
	},

	render: function(){
		console.log("Rendering Product Index Page");
		var grid = this.buildTable();

		var content = this.template({
			products: this.collection,
			categoriesArray: this.categoriesArray
		});

		this.$el.html(content);
		$('#productsTable').html(grid.render().el);

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
			fields: ['category', 'name', 'dosage', 'package'],
			wait: 250
		});

		productsFilter.setfilterColumn("category");
		$('input.categoryFilter').change(function(e) {
			productsFilter.setPickFilter($('input:checkbox.categoryFilter:checked').map(function() {
			    return this.value;
			}).get());
		}); 
		$("#productsTable").prepend(productsFilter.render().el);

		return this;

	},

});