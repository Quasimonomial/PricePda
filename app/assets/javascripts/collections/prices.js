Vetpda.Collections.Prices = Backbone.Collection.extend({
  model: Vetpda.Models.Price,
  url: '/api/prices',

  getOrFetch: function (id) {
    var model = this.get(id),
    prices = this;

    if(model) {
      model.fetch();
    } else {
      model = new JournalApp.Models.Price({ id: id });
      model.fetch({
        success: function () {
          prices.add(model);
        },
      });
    }

    return model;
  }
});