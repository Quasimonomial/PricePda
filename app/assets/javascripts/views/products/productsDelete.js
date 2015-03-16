Vetpda.Views.ProductsDelete = Backbone.View.extend({
	template: JST['products/delete'],

	initialize: function(options){
		console.log("initializing products Delete view");
		this.user = options.user
		this.listenTo(this.user, 'sync', this.render)
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
		  }, {
		  	name: "",
		  	label: "Delete",
		  	cell: DeleteCell,
		  	editable: false
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