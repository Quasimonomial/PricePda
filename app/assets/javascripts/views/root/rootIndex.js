Vetpda.Views.RootIndex = Backbone.View.extend({
	template: JST['root/index'],

	initialize: function(options){
		console.log("Initializing View");
		console.log(options);
		this.companyCollection = options.companies;
		console.log(this.companyCollection);
		this.listenTo(this.companyCollection, 'sync', this.render)
		this.listenTo(this.collection, 'sync', this.render)
	},

	createCompanyCells: function(){
		var companyCells = []
		this.companyCollection.each( function(company) { 
			companyCells.push({
				name: company.get("name"), //.toLowerCase(),
				label: company.get("name"), //.toLowerCase(),
				editable: false,
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
		  	//editable: false
		  }, {
		    name: "name",
		    label: "Product",
		    cell: "string", // An integer cell is a number cell that displays humanized integers
		    //editable: false
		  }, {
		    name: "dosage",
		    label: "Dosage",
		    cell: "string", // A cell type for floating point value, defaults to have a precision 2 decimal numbers
		  	//editable: false
		  }, {
		    name: "package",
		    label: "Package",
		    cell: "string",
		    //editable: false
		  }
		  ].concat(this.createCompanyCells());
		var grid = new Backgrid.Grid({
  			columns: columns,
  			collection: this.collection
		});
		return grid;

	},

	render: function(){
		var grid1 = this.buildTable();

		var content = this.template({
			
		});



		this.$el.html(content);
		$('#productsTable').html(grid1.render().el);
		
		grid1.remove();

		var grid2 = this.buildTable();
		$('#productsTable').html( grid2.render().el );

		return this;
	},

});