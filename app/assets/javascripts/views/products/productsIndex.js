Vetpda.Views.ProductsIndex = Backbone.View.extend({
	template: JST['products/index'],

	initialize: function(){
		console.log("initializing products Index view");
		this.listenTo(this.collection, 'sync add remove', this.render)
	},

	events: {
		'click .productDelete': 'destroyProduct',
		'submit form' : 'addProduct'
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
		var content = this.template({
			products: this.collection
		});

		this.$el.html(content);
		
		return this;
	},

});