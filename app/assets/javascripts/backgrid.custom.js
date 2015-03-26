var DeleteCell = Backgrid.Cell.extend({
    template: _.template('<button>Delete</button>'),
    events: {
      "click": "deleteRow"
    },
    deleteRow: function (e) {
      e.preventDefault();
      //lets ask a confirmation box
      var confirmation = confirm("Are you sure you want to delete this object?");
		if (confirmation == true) {
		    this.model.collection.remove(this.model);
      		this.model.destroy();
		}

    },
    render: function () {
      this.$el.html(this.template());
      this.delegateEvents();
      return this;
    }
});

var CustomButtonCell = Backgrid.Cell.extend({
	initialize: function(options){
		CustomButtonCell.__super__.initialize.apply(this, arguments);
		this.buttonText = options.column.get("buttonText");
		this.callback = options.column.get("callback");
		this.render();
	},

    // template: _.template('<button>' + this.buttonText + '</button>'),

    events: {
      "click": function(event){
      	event.preventDefault();
      	this.callback(this.model);
      }
    },

    render: function () {
      this.$el.html('<button>' + this.buttonText + '</button>');
      this.delegateEvents();
      return this;
    }
});


var StyledByDataRow = Backgrid.Row.extend({
	render: function () {
        var companiesOutOfRange = this.model.get("companiesOutOfRange");
        var coorIndex = 0;
        this.$el.empty();
	    var fragment = document.createDocumentFragment();
	    for (var i = 0; i < this.cells.length; i++) {
	        if(typeof companiesOutOfRange != "undefined"){
		    	if(coorIndex < companiesOutOfRange.length){
		    		if(companiesOutOfRange[coorIndex] === this.cells[i].column.attributes.name){
		    			this.cells[i].el.classList.add("OutOfRange");
		    			coorIndex++;
		    		}
		    	}	        	
	        }
			fragment.appendChild(this.cells[i].render().el);
	    }

	    this.el.appendChild(fragment);

	    this.delegateEvents();
	    return this;
	  }
});





// Subclass Backgrid Filter to pass an extra 'pick' filter
// Also filters out blank shit
Backgrid.ClientSideFilterWithPickFilter = Backgrid.Extension.ClientSideFilter.extend({
  pickFilter: null,

  setfilterColumn: function(value)  {
    this.filterColumn = value;
    return this;
  },

  togglePricesEnteredFilter: function(value) {
    if(this.pricesEnteredFilter){
      this.pricesEnteredFilter = false;
    } else{
      this.pricesEnteredFilter = true;
    }
    this.search();
    return this;
  },

  setPickFilter: function (attrs) {
    this.pickFilter = attrs;
    this.search();
    return this;
  },

  makeMatcher: function (query) {
    var regexp = this.makeRegExp(query);
    return function (model) {
      var json = model.toJSON();


      // Test the pick filter (if set)
      if (this.pickFilter) {
        var inCategory = false

        for(i = 0; i < this.pickFilter.length; i++){
          if(this.pickFilter[i] === model.get(this.filterColumn) ){
            inCategory = true            
            break;
          }
        }

        if (!inCategory) return false;
      }
      if (this.pricesEnteredFilter){
        if(typeof model.get("User") === 'undefined') return false;
      }

      // Test the search filter
      var keys = this.fields || model.keys();
      for (var i = 0, l = keys.length; i < l; i++) {
        if (regexp.test(json[keys[i]] + "")) return true;
      }
      return false;
    };
  }
});