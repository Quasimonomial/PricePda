// var DeleteCell = Backgrid.Cell.extend({
//     template: _.template('<button>Delete</button>'),
//     events: {
//       "click": "deleteRow"
//     },
//     deleteRow: function (e) {
//       console.log("Hello");
//       e.preventDefault();
//       this.model.collection.remove(this.model);
//     },
//     render: function () {
//       this.$el.html(this.template());
//       this.delegateEvents();
//       return this;
//     }
// });

// var PricePercentMinMaxCell = Backgrid.cell.extend({
	
// });

var StyledByDataRow = Backgrid.Row.extend({
	render: function () {
	    //StyledByDataRow.__super__.render.apply(this, arguments);
        var companiesOutOfRange = this.model.get("companiesOutOfRange");
        var coorIndex = 0;
        this.$el.empty();

	    var fragment = document.createDocumentFragment();
	    for (var i = 0; i < this.cells.length; i++) {
	    	if(coorIndex < companiesOutOfRange.length){
	    		if(companiesOutOfRange[coorIndex] === this.cells[i].column.attributes.name){
	    			this.cells[i].el.classList.add("OutOfRange");
	    			coorIndex++;
	    		}
	    	}
			fragment.appendChild(this.cells[i].render().el);
	    }

	    this.el.appendChild(fragment);

	    this.delegateEvents();
	    return this;
	  }
});