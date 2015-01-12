Vetpda.Views.ProductEdit = Backbone.View.extend({
	template: JST['products/edit'],

	initialize: function(){
		console.log("initializing Products Edit view");
		this.listenTo(this.model, 'sync add remove', this.render)
	},

	events: {
		'submit form' : 'submit'
	},

	submit: function(event){
		event.preventDefault();

		var attrs = $(event.target).serializeJSON();
		

		var success = function () {
	      Backbone.history.navigate("products", { trigger: true });
	    }.bind(this)

	    function errors (model, response) {
	      $('.errors').empty();
	      response.responseJSON.forEach(function (el) {
	        var li = $('<li></li>');
	        li.html(el);
	        $('.errors').append(li);
	      }.bind(this));
	    }

	    this.model.save(attrs, {
	      success: success,
	      error: errors.bind(this)
	    });
	},

	render: function(){
		var content = this.template({
			product: this.model
		});

		this.$el.html(content);
		
		return this;
	},

});