/*!
 * jQuery JSON Stringify
 * see also http://www.json.org/
 *
 * Copyright: José Almeida (http://joseafga.com.br)
 * License: MIT (http://opensource.org/licenses/mit-license.php)
 * 
 * Based on: Mootools JSON.encode function (http://mootools.net/) Copyright (c) 2006-2010 Valerio Proietti (http://mad4milk.net/)
 *  
 * Syntax:
 *  $.stringifyJSON(mixed);
 */

(function(jQuery) {
  var special = {'\b': '\\b', '\t': '\\t', '\n': '\\n', '\f': '\\f', '\r': '\\r', '"' : '\\"', '\\': '\\\\'}, 
    escape = function(chr){ return special[chr] || '\\u' + ('0000' + chr.charCodeAt(0).toString(16)).slice(-4); };
   
  jQuery.stringifyJSON = function(data){
    switch (jQuery.type(data)){
      case 'string':
        return '"' + data.replace(/[\x00-\x1f\\"]/g, escape) + '"';
      case 'array':
        return '[' + jQuery.map(data, jQuery.stringifyJSON) + ']';
      case 'object':
        var string = [];
        jQuery.each(data, function(key, val){
          var json = jQuery.stringifyJSON(val);
          if (json) 
            string.push(jQuery.stringifyJSON(key) + ':' + json);
        });
        return '{' + string + '}';
      case 'number': 
      case 'boolean': 
        return '' + data;
      case 'undefined':
      case 'null': 
        return 'null';
    }
    
    return data;
  };

  jQuery.parseJSON = function(data) {
    if (data === null) {
      return data;
    }

    if (jQuery.type(data) == "object") {
      return data;
    }

    if (jQuery.type(data) == "string") {
      // Make sure leading/trailing whitespace is removed (IE can't handle it)
      data = jQuery.trim( data );
      if ( data ) {
        // Make sure the incoming data is actual JSON
        // Logic borrowed from http://json.org/json2.js
        if ( rvalidchars.test( data.replace( rvalidescape, "@" )
          .replace( rvalidtokens, "]" )
          .replace( rvalidbraces, "")) ) {

          return ( new Function( "return " + data ) )();
        }
      }
    }

    jQuery.error( "Invalid JSON: " + data );
  };

})(window.tr8nJQ);