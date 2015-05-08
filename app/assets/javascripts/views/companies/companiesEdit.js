Pricepda.Views.CompanyEdit = Backbone.View.extend({
	template: JST['companies/edit'],

	initialize: function(){
		console.log("initializing Companies Edit view");
		this.listenTo(this.model, 'sync add remove', this.render)
	},

	events: {
		'submit form' : 'submit'
	},

	submit: function(event){
		event.preventDefault();

		console.log($(event.target))
		var attrs = $(event.target).serializeJSON();
		

		var success = function () {
	      Backbone.history.navigate("companies", { trigger: true });
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
			company: this.model
		});

		this.$el.html(content);
		
		return this;
	},

});