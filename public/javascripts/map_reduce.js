var MapReduce = function(options) {
  this.model = options.model;
  this.map = options.map;
  this.reduce = options.reduce;
  this.complete = options.complete;
  this.beforeMap = options.beforeMap;
  this.afterMap = options.afterMap;
  this.beforeReduce = options.beforeReduce;
  this.afterReduce = options.afterReduce;
  this.beforeComplete = options.beforeComplete;
}

MapReduce.prototype = {
  start: function() {
    var thisObj = this;

    new Ajax.Request(
      '/map_reduce/prepare',
      {
        method: 'post',
        parameters: 'p=' + Math.floor(Math.random() * 1000000) +
                    '&model=' + thisObj.model,

        onLoading: function(request) {
          $('status').innerHTML = 'waiting...';
        },

        onComplete: function(request) {
          if (request.responseText == 'over') {
            $('status').innerHTML = 'over';
            return;
          }

          $('status').innerHTML = 'processing map phase';

          if (thisObj.beforeMap != 'undefined') {
            thisObj.beforeMap(request.responseText);
          }

          var res = eval('(' + request.responseText + ')');

          var mapProc = new MapReduceProc(thisObj.map);

          // map phase
          for (var r in res) {
            mapProc.proc(r, res[r]);
          }

          var result = thisObj.toRubyHash(mapProc.data);

          if (thisObj.afterMap != 'undefined') {
            thisObj.afterMap(result);
          }

          // shuffle phase
          thisObj.requestShuffle(result, thisObj);
        }
      });
  },

  requestShuffle: function(mapResult, thisObj) {
    new Ajax.Request(
      '/map_reduce/shuffle',
      {
        method: 'post',
        parameters: 'map=' + mapResult + 
                    '&model=' + thisObj.model,

        onLoading: function(request) {
          $('status').innerHTML = 'processing shuffle phase';
        },

        onComplete: function(request) {
          $('status').innerHTML = 'processing reduce phase';

          if (thisObj.beforeReduce != 'undefined') {
            thisObj.beforeReduce(request.responseText);
          }

          var res = eval('(' + request.responseText + ')');

          var reduceProc = new MapReduceProc(thisObj.reduce);

          // reduce phase
          for (var r in res) {
            reduceProc.proc(r, res[r]);
          }

          var result = thisObj.toRubyHash(reduceProc.data);

          if (thisObj.afterReduce != 'undefined') {
            thisObj.afterReduce(result);
          }

          // final phase
          thisObj.requestComplete(result, thisObj);
        }
      });
  },

  requestComplete: function(reduceResult, thisObj) {
    new Ajax.Request(
      '/map_reduce/complete',
      {
        method: 'post',
        parameters: 'reduce=' + reduceResult +
                    '&model=' + thisObj.model,

        onLoading: function(request) {
          $('status').innerHTML = 'processing final phase';
        },

        onComplete: function(request) {
          if (thisObj.beforeComplete != 'undefined') {
            thisObj.beforeComplete(request.responseText);
          }

          var response = eval("(" + request.responseText + ")");

          if (thisObj.complete != 'undefined') {
            thisObj.complete(response);
          }

          $('status').innerHTML = 'complete';
        }
      });
  },

  toRubyHash: function(obj) {
    var hash = '{';
    for (var key in obj) {
      if (typeof(obj[key]) != 'function') {
        hash += '"' + key + '" => "' + obj[key] + '", ';
      }
    }
    hash = hash.substr(0, hash.length - 2) + '}';

    return hash;
  }
};

var MapReduceProc = function(proc) {
  this.proc = proc;
  this.data = {};
}

MapReduceProc.prototype = {
  emit: function(key, value) {
    if (this.data[key]) {
      this.data[key] = this.data[key] + "," + value;
    } else {
      this.data[key] = value;
    }
  }
}
