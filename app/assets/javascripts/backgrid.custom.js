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

var StyledByDataRow = Backgrid.Row.extend({
	render: function () {
      var companiesOutOfRange = this.model.get("companiesOutOfRange");
      var companiesAboveRange = this.model.get("companiesAboveRange");

      this.$el.empty();
	    var fragment = document.createDocumentFragment();
	    for (var i = 0; i < this.cells.length; i++) {
        if(typeof companiesOutOfRange != "undefined"){
        	if(companiesOutOfRange.indexOf(this.cells[i].column.attributes.name) >= 0){
        		this.cells[i].el.classList.add("OutOfRange");
        	}        	
        }

        if(typeof companiesAboveRange != "undefined"){
          if(companiesAboveRange.indexOf(this.cells[i].column.attributes.name) >= 0){
            this.cells[i].el.classList.add("aboveRange");
          }         
        }
        
        // this.cells[i].el.classList.add(this.cells[i].column.attributes.name);
        if(this.cells[i].column.attributes.name === "min"){
          this.cells[i].el.classList.add("min");
        } 
        if(this.cells[i].column.attributes.name === "average"){
          this.cells[i].el.classList.add("average");
        } 
        if(this.cells[i].column.attributes.name === "max"){
          this.cells[i].el.classList.add("max");
        } 
        if(this.cells[i].column.attributes.name === "percentDifference"){
          this.cells[i].el.classList.add("percentDifference");
        }
        if(this.cells[i].column.attributes.name === "User"){
          this.cells[i].el.classList.add("user");
        }

			  fragment.appendChild(this.cells[i].render().el);
	    }

	    this.el.appendChild(fragment);

	    this.delegateEvents();
	    return this;
	  }
});




//Filter can be used along with a search bar to filter by categories, or can be used to filter by Products the User has entered prices for
Backgrid.ClientSideFilterWithPickFilter = Backgrid.Extension.ClientSideFilter.extend({
  pickFilter: null,

  setfilterColumn: function(value)  {
    this.filterColumn = value;
    return this;
  },

  togglePricesEnteredFilter: function(value) {
    if(this.pricesEnteredFilter == true){
      this.pricesEnteredFilter = false;
    } else{
      this.pricesEnteredFilter = true;
    }
    this.search();
    return this;
  },

  toggleRedFilter: function(value) {
    if(this.redProductsFilter == true){
      this.redProductsFilter = false;
    } else{
      this.redProductsFilter = true;
    }
    this.search();
    return this;
  },

  toggleGreenFilter: function(value) {
    if(this.greenProductsFilter == true){
      this.greenProductsFilter = false;
    } else{
      this.greenProductsFilter = true;
    }
    this.search();
    return this;
  },

  search: function () {
    var matcher = _.bind(this.makeMatcher(this.query()), this);
    var col = this.collection;
    // if (col.pageableCollection) col.pageableCollection.getFirstPage({silent: true});
    console.log("searching")
    console.log(col)
    console.log(col.pageableCollection)
    console.log(col.pageableCollection.state)
    col.reset(this.shadowCollection.filter(matcher), {reindex: false});
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
      if (this.pricesEnteredFilter === true){
        if(typeof model.get("User") === 'undefined') return false;
      }

      if (this.redProductsFilter === true){
        if(model.get("companiesOutOfRange").length < 1) return false; 
      }

      if (this.greenProductsFilter === true){
        if(model.get("companiesAboveRange").length < 1) return false; 
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