Vetpda.Collections.Companies = Backbone.Collection.extend({
  model: Vetpda.Models.Company,
  url: '/api/companies',

  filterByEnabled: function(bool) {
    filtered = this.filter(function(company) {
      return company.get("enabled") === bool;
      });
    return new Vetpda.Collections.Companies(filtered);
  },

  getOrFetch: function (id) {
    var model = this.get(id),
    companies = this;

    if(model) {
      model.fetch();
    } else {
      model = new Vetpda.Models.Company({ id: id });
      model.fetch({
        success: function () {
          companies.add(model);
        },
      });
    }

    return model;
  }
});

Vetpda.companies = new Vetpda.Collections.Companies