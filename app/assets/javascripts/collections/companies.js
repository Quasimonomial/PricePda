Pricepda.Collections.Companies = Backbone.Collection.extend({
  model: Pricepda.Models.Company,
  url: '/api/companies',

  getOrFetch: function (id) {
    var model = this.get(id),
    companies = this;

    if(model) {
      model.fetch();
    } else {
      model = new Pricepda.Models.Company({ id: id });
      model.fetch({
        success: function () {
          companies.add(model);
        },
      });
    }

    return model;
  }
});

Pricepda.companies = new Pricepda.Collections.Companies