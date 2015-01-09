Vetpda.Routers.VetRouter = Backbone.Router.extend({
	initialize: function (options) {
		this.$rootEl = options.$rootEl;
 	},

	routes: {
		'': 'rootIndex',
		'companies': 'companies',
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

	_swapView: function (view) {
		this._currentView && this._currentView.remove();
		this._currentView = view;
		this.$rootEl.html(view.render().$el);
	}

});