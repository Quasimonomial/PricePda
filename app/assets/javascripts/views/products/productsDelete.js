Vetpda.Views.ProductsDelete = Backbone.View.extend({
	template: JST['products/delete'],

	initialize: function(options){
		console.log("initializing products Delete view");
		this.listenTo(this.collection, 'sync add remove', this.render)
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
	},

	saveAllProducts: function(){
		this.collection.each(function(product){
			product.save();
		});
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
		  }, {
		  	name: "",
		  	label: "Delete",
		  	cell: DeleteCell
		  }, {
		    name: "enabled",
		    label: "Enabled?",
		    cell: "boolean",
		    editable: true
		  }

		  ];
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection
		});
		return grid;
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