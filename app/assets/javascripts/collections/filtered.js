filteredCollection = function(original, filterFn) {
  console.log(original)
  console.log(filterFn)
  var filtered;
 
  // Instantiate new collection
  filtered = new original.constructor();
 
  // Remove events associated with original
  filtered._callbacks = {};
 
  filtered.filterItems = function(filter) {
    var items;
    items = original.filter(filter);
    filtered._currentFilter = filterFn;
    return filtered.reset(items);
  };
 
  // Refilter when original collection is modified
  original.on('reset change destroy', function() {
    return filtered.filterItems(filtered._currentFilter);
  });
 
  return filtered.filterItems(filterFn);
};