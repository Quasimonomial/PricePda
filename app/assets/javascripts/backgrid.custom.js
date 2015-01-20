var DeleteCell = Backgrid.Cell.extend({
    template: _.template('<button>Delete</button>'),
    events: {
      "click": "deleteRow"
    },
    deleteRow: function (e) {
      console.log("Hello");
      e.preventDefault();
      this.model.collection.remove(this.model);
    },
    render: function () {
      this.$el.html(this.template());
      this.delegateEvents();
      return this;
    }
});