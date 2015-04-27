Vetpda.Routers.VetRouter = Backbone.Router.extend({
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
		var currentUser = new Vetpda.Models.User();
		currentUser.fetch();
		Vetpda.products.fetch();
		Vetpda.companies.fetch();
		var indexView = new Vetpda.Views.RootIndex({
			collection: Vetpda.products,
			companies: Vetpda.companies,
			user: currentUser
		});
		this._swapView(indexView);
	},

	companies: function(){
		var that = this;
		console.log("routing to companies page")
		Vetpda.companies.fetch();
		var currentUser = new Vetpda.Models.User();
		var companiesView = new Vetpda.Views.CompaniesIndex({
			collection: Vetpda.companies
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

		var company = Vetpda.companies.getOrFetch(id);
		console.log("routing to companies");
		var currentUser = new Vetpda.Models.User();
		var companyView = new Vetpda.Views.CompanyEdit({
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
		Vetpda.products.fetch();
		Vetpda.companies.fetch();
		var currentUser = new Vetpda.Models.User();
		var productsView = new Vetpda.Views.ProductsIndex({
			collection: Vetpda.products,
			companies: Vetpda.companies,
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
		Vetpda.products.fetch();
		var currentUser = new Vetpda.Models.User();
		var productsView = new Vetpda.Views.ProductsDelete({
			collection: Vetpda.products,
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

	// productShow: function(id){
	// 	var product = Vetpda.products.getOrFetch(id);
	// 	Vetpda.companies.fetch();
	// 	console.log("routing to product show page");
	// 	var productView = new Vetpda.Views.ProductShow({
	// 		model: product,
	// 		collection: Vetpda.companies
	// 	});
	// 	this._swapView(productView);
	// },

	_swapView: function (view) {
		this._currentView && this._currentView.remove();
		this._currentView = view;
		this.$rootEl.html(view.render().$el);
	}
});
