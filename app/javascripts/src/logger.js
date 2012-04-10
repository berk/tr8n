/****************************************************************************
  Copyright (c) 2010-2012 Michael Berkovich, Ian McDaniel, tr8n.net

  Permission is hereby granted, free of charge, to any person obtaining
  a copy of this software and associated documentation files (the
  "Software"), to deal in the Software without restriction, including
  without limitation the rights to use, copy, modify, merge, publish,
  distribute, sublicense, and/or sell copies of the Software, and to
  permit persons to whom the Software is furnished to do so, subject to
  the following conditions:

  The above copyright notice and this permission notice shall be
  included in all copies or substantial portions of the Software.

  THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
  EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
  MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
  NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
  LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
  OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
  WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
****************************************************************************/

Tr8n.Proxy.Logger = function(options) {
  this.options = options;
  this.object_keys = [];
}

Tr8n.Proxy.Logger.prototype = {
  clear: function() {
    if (!this.options['proxy'].logger_enabled) return;
    if (!this.options['element_id']) return;
    if (!Tr8n.element(this.options['element_id'])) return;
    Tr8n.element(this.options['element_id']).innerHTML = ""; 
  },
  append: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    if (!this.options['element_id']) return;
    if (!Tr8n.element(this.options['element_id'])) return;

    var str = msg + "<br>" + Tr8n.element(this.options['element_id']).innerHTML;
    Tr8n.element(this.options['element_id']).innerHTML = str; 
  },
  log: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    var now = new Date();
    var str = "<span style='color:#ccc;'>" + (now.toLocaleDateString() + " " + now.toLocaleTimeString()) + "</span>: " + msg;  
    this.append(str); 
  },
  debug: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    if (window.console && console.log) {
       console.log(msg);
    }
    this.log("<span style='color:grey'>" + msg + "</span>");
  },
  error: function(msg) {
    if (!this.options['proxy'].logger_enabled) return;
    if (window.console && console.error) {
       console.error(msg);
    }
    this.log("<span style='color:red'>" + msg + "</span>");
  },
  S4: function() {
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },
  guid: function() {
    return (this.S4()+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+"-"+this.S4()+this.S4()+this.S4());
  },
  escapeHTML: function(str) { 
    return( str.replace(/&/g,'&amp;').replace(/>/g,'&gt;').replace(/</g,'&lt;').replace(/"/g,'&quot;')); 
  },
  showObject: function (obj_key, flag) {
    if (flag) {
      Tr8n.Effects.hide("no_object_" + obj_key);
      Tr8n.Effects.show("object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='/assets/tr8n/minus_node.png'>";
    } else {
      Tr8n.Effects.hide("object_" + obj_key);
      Tr8n.Effects.show("no_object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='/assets/tr8n/plus_node.png'>";
    } 
  },
  toggleNode: function(obj_key) {
    this.showObject(obj_key, (Tr8n.element("object_" + obj_key).style.display == 'none'));
  },
  expandAllNodes: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.showObject(this.object_keys[i], true);
    }
  },
  collapseAllNodes: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.showObject(this.object_keys[i], false);
    }
  },
  logObject: function(data) {
    this.object_keys = [];
    html = []
    html.push("<div style='float:right;padding-right:10px;'>");
    html.push("<span style='padding:2px;' onClick=\"tr8nProxy.logger.expandAllNodes()\"><img src='/assets/tr8n/plus_node.png'></span>");
    html.push("<span style='padding:2px;' onClick=\"tr8nProxy.logger.collapseAllNodes()\"><img src='/assets/tr8n/minus_node.png'></span>");
    html.push("</div>");

    var results = data;
    if (typeof results == 'string') {
      try {
        results = eval("[" + results + "]")[0];
      } 
      catch (err) {
        this.push(results);
        return;
      }
    }
    if (typeof results == 'object') {
      html.push(this.formatObject(results, 1));
    } else {
      html.push(results);
    }
    this.append(html.join(""));
  },
  formatObject: function(obj, level) {
    if (obj == null) return "{<br>}";

    var html = [];
    var obj_key = this.guid();  
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"tr8nProxy.logger.toggleNode('" + obj_key + "')\"><img src='/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>{...}</span> <span id='object_" + obj_key + "'>{");
    this.object_keys.push(obj_key);

    var keys = Object.keys(obj).sort();

    for (var i=0; i<keys.length; i++) {
      key = keys[i];
      if (this.isObject(obj[key])) {
        if (this.isArray(obj[key])) {
          html.push(this.createSpacer(level) + "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + this.formatArray(obj[key], level + 1) + ",");
        } else {
          html.push(this.createSpacer(level) + "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + this.formatObject(obj[key], level + 1) + ",");
        }
      } else {
        html.push(this.createSpacer(level) + this.formatProperty(key, obj[key]) + ",");
      }
    }
    html.push(this.createSpacer(level-1) + "}</span>");
    return html.join("<br>");
  },
  formatArray: function(arr, level) {
    if (arr == null) return "[<br>]";

    var html = [];
    var obj_key = this.guid();  
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"tr8nProxy.logger.toggleNode('" + obj_key + "')\"><img src='/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>[...]</span> <span id='object_" + obj_key + "'>[");
    this.object_keys.push(obj_key);

    for (var i=0; i<arr.length; i++) {
      if (this.isObject(arr[i])) {
        if (this.isArray(arr[i])) {
           html.push(this.createSpacer(level) + this.formatArray(arr[i], level + 1) + ","); 
        } else {
           html.push(this.createSpacer(level) + this.formatObject(arr[i], level + 1) + ",");  
        }     
      } else {
        html.push(this.createSpacer(level) + this.formatProperty(null, arr[i]) + ",");
      }
    }  
    html.push(this.createSpacer(level-1) + "]</span>");
    return html.join("<br>");
  },
  formatProperty: function(key, value) {
    if (value == null) return "<span class='tr8n_logger_obj_key'>" + key + ":</span><span class='obj_value_null'>null</span>";
    
    var cls = "tr8n_logger_obj_value_" + (typeof value);
    var value_span = "";
    
    if (this.isString(value)) 
      value_span = "<span class='" + cls + "'>\"" + this.escapeHTML(value) + "\"</span>";
    else
      value_span = "<span class='" + cls + "'>" + value + "</span>";
       
    if (key == null)
      return value_span;
      
    return "<span class='tr8n_logger_obj_key'>" + key + ":</span>" + value_span;
  },
  createSpacer: function(level) {
    return "<img src='/assets/tr8n/pixel.gif' style='height:1px;width:" + (level * 20) + "px;'>";
  },
  isArray: function(obj) {
    if (obj == null) return false;
    return !(obj.constructor.toString().indexOf("Array") == -1);
  },
  isObject: function(obj) {
    if (obj == null) return false;
    return (typeof obj == 'object');
  },
  isString: function(obj) {
    return (typeof obj == 'string');
  },
  isURL: function(str) {
    str = "" + str;
    return (str.indexOf("http://") != -1) || (str.indexOf("https://") != -1);
  }
}
