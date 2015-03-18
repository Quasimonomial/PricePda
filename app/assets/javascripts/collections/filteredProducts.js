Vetpda.Collections.FilteredProducts = Backbone.PageableCollection.extend({
  model: Vetpda.Models.Product,
  url: '/api/products/filtered',

  mode: "client",

  getOrFetch: function (id) {
    var model = this.get(id),
    products = this;

    if(model) {
      model.fetch();
    } else {
      model = new Vetpda.Models.Product({ id: id });
      model.fetch({
        success: function () {
          products.add(model);
        },
      });
    }

    return model;
  }
});

Vetpda.filteredProducts = new Vetpda.Collections.FilteredProducts