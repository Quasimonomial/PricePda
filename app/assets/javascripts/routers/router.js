Vetpda.Routers.VetRouter = Backbone.Router.extend({
	initialize: function (options) {
		this.$rootEl = options.$rootEl;
 	},

	routes: {
		'': 'rootIndex',
		'companies': 'companies',
		'companies/:id/edit': 'companiesEdit', 
		'products' : 'productsIndex',
		'products/:id': 'productShow',
		'prices/input/user': 'inputUserPrices',
		'prices/input/:id': 'inputCompanyPrices'
	},

	rootIndex: function(){
		console.log("reaching root js index")
		var indexView = new Vetpda.Views.RootIndex();
		this._swapView(indexView);
	},

	companies: function(){
		console.log("routing to companies page")
		Vetpda.companies.fetch();
		var companiesView = new Vetpda.Views.CompaniesIndex({
			collection: Vetpda.companies
		});
		this._swapView(companiesView);
	},

	companiesEdit: function(id){
		var company = Vetpda.companies.getOrFetch(id);
		console.log("routing to companies");
		var companyView = new Vetpda.Views.CompanyEdit({
			model: company
		});
		this._swapView(companyView);
	},

	productsIndex: function(){
		console.log("Routing to Product Index");
		Vetpda.products.fetch();
		var productsView = new Vetpda.Views.ProductsIndex({
			collection: Vetpda.products
		});
		this._swapView(productsView);
	},

	productShow: function(){

	},

	_swapView: function (view) {
		this._currentView && this._currentView.remove();
		this._currentView = view;
		this.$rootEl.html(view.render().$el);
	}

});