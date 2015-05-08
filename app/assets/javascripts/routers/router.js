Pricepda.Routers.VetRouter = Backbone.Router.extend({
	initialize: function (options) {
		this.$rootEl = options.$rootEl;
 	},

	routes: {
		'': 'rootIndex',
		'companies': 'companies',
		'companies/:id/edit': 'companiesEdit', 
		'products' : 'productsIndex',
		'products/delete': 'productsDelete'
		//'products/:id': 'productShow'
	},

	rootIndex: function(){
		console.log("reaching root js index")
		var currentUser = new Pricepda.Models.User();
		currentUser.fetch();
		Pricepda.products.fetch();
		Pricepda.companies.fetch();
		var indexView = new Pricepda.Views.RootIndex({
			collection: Pricepda.products,
			companies: Pricepda.companies,
			user: currentUser
		});
		this._swapView(indexView);
	},

	companies: function(){
		var that = this;
		console.log("routing to companies page")
		Pricepda.companies.fetch();
		var currentUser = new Pricepda.Models.User();
		var companiesView = new Pricepda.Views.CompaniesIndex({
			collection: Pricepda.companies
		});

		currentUser.fetch({
			success: function () {
		    	if(currentUser.get("is_admin") ===true){
					that._swapView(companiesView);
		    	} else{
		    		Backbone.history.navigate("#/", {trigger: true});
		    	}
			}
		});
	},

	companiesEdit: function(id){
		var that = this;

		var company = Pricepda.companies.getOrFetch(id);
		console.log("routing to companies");
		var currentUser = new Pricepda.Models.User();
		var companyView = new Pricepda.Views.CompanyEdit({
			model: company
		});

		currentUser.fetch({
			success: function () {
		    	if(currentUser.get("is_admin") ===true){
					that._swapView(companyView);
		    	} else{
		    		Backbone.history.navigate("#/", {trigger: true});
		    	}
			}
		});
	},

	productsIndex: function(){
		var that = this;

		console.log("Routing to Product Index");
		Pricepda.products.fetch();
		Pricepda.companies.fetch();
		var currentUser = new Pricepda.Models.User();
		var productsView = new Pricepda.Views.ProductsIndex({
			collection: Pricepda.products,
			companies: Pricepda.companies,
			user: currentUser
		});

		currentUser.fetch({
			success: function () {
		    	if(currentUser.get("is_admin") ===true){
					that._swapView(productsView);
		    	} else{
		    		Backbone.history.navigate("#/", {trigger: true});
		    	}
			}
		});
	},

	productsDelete: function(){
		var that = this;
		console.log("Routing to Product Delete Page");
		Pricepda.products.fetch();
		var currentUser = new Pricepda.Models.User();
		var productsView = new Pricepda.Views.ProductsDelete({
			collection: Pricepda.products,
			user: currentUser
		});

		currentUser.fetch({
			success: function () {
		    	if(currentUser.get("is_admin") ===true){
					that._swapView(productsView);
		    	} else{
		    		Backbone.history.navigate("#/", {trigger: true});
		    	}
			}
		});
	},	

	_swapView: function (view) {
		this._currentView && this._currentView.remove();
		this._currentView = view;
		this.$rootEl.html(view.render().$el);
	}
});
