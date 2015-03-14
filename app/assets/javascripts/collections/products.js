Vetpda.Collections.Products = Backbone.PageableCollection.extend({
  model: Vetpda.Models.Product,
  url: '/api/products',

  // Initial pagination states
  mode: "client",
    
    // state: {
    //   pageSize: 3,
    //  /* sortKey: "updated",*/
    //   order: 1
    // },


    // queryParams: {
    //   totalPages: null,
    //   totalRecords: null,
    //   sortKey: "sort"
    // },



    // parseState: function (resp, queryParams, state, options) {
    //   return {totalRecords: resp.total_pages};
    // },


    // parseRecords: function (resp, options) {
    //   return resp.listings;
    // }

  // state: {
  //   pageSize: 30,
  //   // You can use 0-based or 1-based indices, the default is 1-based.
  //   // You can set to 0-based by setting ``firstPage`` to 0.
  //   firstPage: 1,
  //   mode: "server"
  //   // Set this to the initial page index if different from `firstPage`. Can
  //   // also be 0-based or 1-based.
  //   // currentPage: 2,

  //   // totalRecords: 200
  // },

  // queryParams: {
  //   currentPage: "current_page",
  //   pageSize: "page_size"
  // },
  // state: {
  //   pageSize: 25,
  //   sortKey: "updated",
  //   order: 1
  // },

  // queryParams: {
  //   totalPages: null,
  //   totalRecords: null,
  //   sortKey: "sort",
  //   //q: "state:closed repo:jashkenas/backbone"
  // },

  // parseState: function (resp, queryParams, state, options) {
  //   return {totalRecords: resp.total_count};
  // },

  // parseRecords: function (resp, options) {
  //   return resp.items;
  // },


  // parse: function(response){
  //   return response
  // },

  // getOrFetch: function (id) {
  //   var model = this.get(id),
  //   products = this;

  //   if(model) {
  //     model.fetch();
  //   } else {
  //     model = new Vetpda.Models.Product({ id: id });
  //     model.fetch({
  //       success: function () {
  //         products.add(model);
  //       },
  //     });
  //   }

  //   return model;
  // }
});

Vetpda.products = new Vetpda.Collections.Products