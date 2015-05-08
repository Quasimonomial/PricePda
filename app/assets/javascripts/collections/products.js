Pricepda.Collections.Products = Backbone.PageableCollection.extend({
  model: Pricepda.Models.Product,
  url: '/api/products',

  // Initial pagination states
  mode: "client",
    
   
  getOrFetch: function (id) {
    var model = this.get(id),
    products = this;

    if(model) {
      model.fetch();
    } else {
      model = new Pricepda.Models.Product({ id: id });
      model.fetch({
        success: function () {
          products.add(model);
        },
      });
    }

    return model;
  }
});

Pricepda.products = new Pricepda.Collections.Products