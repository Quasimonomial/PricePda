Vetpda.Views.RootIndex = Backbone.View.extend({
	template: JST['root/index'],

	initialize: function(options){
		console.log("Initializing View");
		this.companyCollection = options.companies;
		this.listenTo(this.companyCollection, 'sync', this.render)
		this.listenTo(this.collection, 'sync', this.render)
	},

	events: {
		'click .saveProducts': 'saveAllProducts',
		'click .tableFilter' : 'renderTable'
	},

	saveAllProducts: function(){
		console.log(this.collection);//.save();
		this.collection.each(function(product){
			product.save();
		});
	},

	activeCompanies: function(){
		return $('input:checkbox:checked').map(function() {
		    return this.value;
		}).get();
	},
	
	calculateProductStats: function(){
		var activeCompanies = this.activeCompanies();
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
				average: pricesArrSum/pricesArr.length
			});
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
  			collection: this.collection
		});
		return grid;

	},

	renderTable: function(){
		this.calculateProductStats();
		var grid = this.buildTable();
		$('#productsTable').html(grid.render().el);
	},

	render: function(){
		
		var content = this.template({
			companies: this.companyCollection
		});



		this.$el.html(content);
		this.renderTable();

		return this;
	},

});