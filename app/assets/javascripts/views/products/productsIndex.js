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
		'submit form' : 'addProduct'
	},

	saveAllProducts: function(){
		console.log(this.collection);//.save();
		this.collection.each(function(product){
			product.save();
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
		  }//, {
		  // 	name: "",
		  // 	label: "Delete",
		  // 	cell: DeleteCell
		  // }

		  ].concat(this.createCompanyCells());
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

	destroyProduct: function(event){
		event.preventDefault();

		var $target = $(event.currentTarget);

		console.log($target);
		console.log($target.attr('data-id'));

		var product = this.collection.get($target.attr('data-id'));
		product.destroy();
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