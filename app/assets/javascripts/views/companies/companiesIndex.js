Vetpda.Views.CompaniesIndex = Backbone.View.extend({
	template: JST['companies/index'],

	initialize: function(){
		console.log("initializing Companies Index view");
		console.log(this.collection)
		this.listenTo(this.collection, 'sync add remove', this.render)
	},

	events: {
		'click .companyDelete': 'destroyCompany',
		'submit form' : 'addCompany'
	},

	addCompany: function(event){
		event.preventDefault();

		var company = new Vetpda.Models.Company
		
		console.log('adding a company');
		console.log($(event.target))
		var attrs = $(event.target).serializeJSON();
		

		var success = function () {
	      console.log("win");
	      this.collection.add(company, { merge: true });
	      //Backbone.history.navigate("", { trigger: true });
	    }.bind(this)

	    function errors (model, response) {
	      console.log("fail");
	      $('.errors').empty();
	      response.responseJSON.forEach(function (el) {
	        var li = $('<li></li>');
	        li.html(el);
	        $('.errors').append(li);
	      }.bind(this));
	    }

	    company.save(attrs, {
	      success: success,
	      error: errors.bind(this)
	    });
	},

	destroyCompany: function(event){
		event.preventDefault();

		var $target = $(event.currentTarget);

		console.log($target);
		console.log($target.attr('data-id'));

		var company = this.collection.get($target.attr('data-id'));
		company.destroy();
		console.log("Destroy");
	},

	render: function(){
		var content = this.template({
			companies: this.collection
		});

		this.$el.html(content);
		
		return this;
	},

});