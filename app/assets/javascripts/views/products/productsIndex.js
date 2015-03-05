Vetpda.Views.ProductsIndex = Backbone.View.extend({
	template: JST['products/index'],

	initialize: function(options){
		console.log("initializing products Index view");
		this.companyCollection = options.companies;
		this.listenTo(this.companyCollection, 'sync', this.render)
		this.listenTo(this.collection, 'sync add remove', this.render)
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
		'click .emailAll': 'emailAll',
		'submit .productAdd' : 'addProduct',
		'submit .uploadProducts' : 'uploadProductsFile'
	},

	uploadProductsFile: function(event){
		event.preventDefault();
		console.log("importing file")
		var attrs = $(event.target);
		console.log($(event.target).find("#productsSheet").prop('files')[0]);
		$.ajax({
			url: "excel/import_products",
			method: "POST",
  			iframe: true,
  			files: $(event.target).find("#productsSheet"),
 			success: function(){
 				this.render();
				console.log("Ajax succeeded");
			}
		});
	},

	saveAllProducts: function(){
		console.log(this.collection);//.save();
		this.collection.each(function(product){
			product.save();
		});
	},

	emailAll: function(){
		$.ajax({
			url: "/email/send_to_all",
			method: "POST",
  			dataType: 'json',
  			// complete: function(response, textStatus) {
   		// 	 return alert("Hey: " + textStatus);
  			// },
			success: function(){
				console.log("Ajac succeeded");
				alert("Emails Sent Successfully");
			}
		});
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
		
	buildTable: function(){
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
		  	//editable: true
		  }, {
		    name: "name",
		    label: "Product",
		    cell: "string", // An integer cell is a number cell that displays humanized integers
		    //editable: true
		  }, {
		    name: "dosage",
		    label: "Dosage",
		    cell: "string", // A cell type for floating point value, defaults to have a precision 2 decimal numbers
		  	//editable: true
		  }, {
		    name: "package",
		    label: "Package",
		    cell: "string",
		    //editable: true
		  }].concat(this.createCompanyCells());
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection
		});
		return grid;
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

	render: function(){
		var grid = this.buildTable();

		var content = this.template({
			products: this.collection
		});

		this.$el.html(content);
		$('#productsTable').html(grid.render().el);
		return this;
	},

});