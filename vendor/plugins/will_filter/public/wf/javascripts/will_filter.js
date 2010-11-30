/****************************************************************************
  Copyright (c) 2010 Michael Berkovich, Geni Inc

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

/****************************************************************************
**** Generic Helper Functions
****************************************************************************/

var Wf = Wf || {
  element:function(element_id) {
		if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },
  value:function(element_id) {
    return Wf.element(element_id).value;
  },
  hide: function(element_id) {
    Wf.element(element_id).style.display = "none";
  },
  visible: function(element_id) {
    return (Wf.element(element_id).style.display != "none");
  },
  hidden: function(element_id) {
    return (!Wf.visible(element_id));
  },
  show: function(element_id) {
    var style = (Wf.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Wf.element(element_id).style.display = style;
  },
  submit: function(element_id) {
    Wf.element(element_id).submit();
  },
  focus: function(element_id) {
    Wf.element(element_id).focus();
  },
  scrollTo: function(element_id) {
    var theElement = Wf.element(element_id);
    var selectedPosX = 0;
    var selectedPosY = 0;
    while(theElement != null){
      selectedPosX += theElement.offsetLeft;
      selectedPosY += theElement.offsetTop;
      theElement = theElement.offsetParent;
    }
    window.scrollTo(selectedPosX,selectedPosY);
  }	
};

/****************************************************************************
**** Effects Functions
**** The functions can be overloaded using a specific framework
****************************************************************************/
Wf.Effects = {
  blindUp: function(element_id) {
    Wf.hide(element_id);    
  },
  blindDown: function(element_id) {
    Wf.show(element_id);    
  },
  appear: function(element_id) {
    Wf.show(element_id);
  },
  fade: function(element_id) {
    Wf.hide(element_id);
  },
};

/****************************************************************************
**** Filter Container
****************************************************************************/

Wf.Filter = function(options){
	var self = this;
  this.original_form_action = null;
}

Wf.Filter.prototype = {
  showSpinner: function() {
    Wf.show("wf_loader");
  },
  hideSpinner: function() {
    Wf.hide("wf_loader");
  },
  toggleDebugger: function() {
		if (Wf.visible("wf_debugger")) {
			new Wf.Effects.blindUp("wf_debugger");
		} else {	
		  new Wf.Effects.blindDown("wf_debugger");
		}
	},
	markDirty: function() {
	  if (Wf.element("wf_key") && Wf.value("wf_id") == "") {
	    Wf.element("wf_key").value = "";
	  }
	},
	fieldChanged: function(fld) {
	  Wf.element(fld).style.border = "1px solid red";
	  this.markDirty();
	},
	saveFilter: function() {
    var filter_name = prompt("Please provide a name for the new filter:", "");
    if (filter_name == null) return;
    Wf.element("wf_name").value = filter_name;   
    this.showSpinner();
    this.updateFilterConditions('save_filter', Wf.Utils.serializeForm('wf_form'));
	},
  updateFilter: function() {
    var filter_name = prompt("Please provide a name for this filter:", Wf.value("wf_name"));
    if (filter_name == null) return;
    Wf.element("wf_name").value = filter_name;   
		this.showSpinner();
    this.updateFilterConditions('update_filter', Wf.Utils.serializeForm('wf_form'));
  },
  deleteFilter: function() {
		if (!confirm("Are you sure you want to delete this filter?")) return;
    this.showSpinner();
    this.updateFilterConditions('delete_filter', Wf.Utils.serializeForm('wf_form'));
  },
  updateConditionAt: function(index) {
    this.showSpinner();
    this.markDirty();
    var data_hash = Wf.Utils.serializeForm('wf_form');
    data_hash["at_index"] = index;
    this.updateFilterConditions('update_condition', data_hash);
  },
	removeConditionAt: function(index) {
    this.showSpinner();
    this.markDirty();
    var data_hash = Wf.Utils.serializeForm('wf_form');
    data_hash["at_index"] = index;
    this.updateFilterConditions('remove_condition', data_hash);
	},
  removeAllConditions: function() {
    this.showSpinner();
    this.markDirty();
    this.updateFilterConditions('remove_all_conditions', Wf.Utils.serializeForm('wf_form'));
  },
	addCondition: function() {
    this.addConditionAfter(-1);
	},
  addConditionAfter: function(index) {
    this.showSpinner();
    this.markDirty();
    var data_hash = Wf.Utils.serializeForm('wf_form');
    data_hash["after_index"] = index;
		this.updateFilterConditions('add_condition', data_hash);
  },
	updateFilterConditions: function(action, data_hash) {
    Wf.Utils.update('wf_filter_conditions', '/wf/filter/' + action, {
      parameters: data_hash,
      evalScripts: true,
      onComplete: function(transport) {
        wfFilter.hideSpinner();
      } 
    });
	},	
	loadSavedFilter: function() {
	  if (Wf.value("wf_key") == "-1" || Wf.value("wf_key") == "-2")
	    return;
	
	  this.showSpinner();
	  var data_hash = Wf.Utils.serializeForm('wf_form');
	
    Wf.Utils.update('wf_filter_conditions', '/wf/filter/load_filter', {
      parameters: data_hash,
      evalScripts: true,
      onComplete: function(transport) {
        wfFilter.submit();
      } 
    });
	},
	submit: function() {
    if (this.original_form_action != "") 
        Wf.element('wf_form').action = this.original_form_action;
		
    Wf.element('wf_submitted').value = 'true';
    Wf.submit('wf_form');
	}
};

/****************************************************************************
**** Filter Calendar
****************************************************************************/

Wf.Calendar = function(options) {
  this.options = options || {};
  this.trigger = null;
  this.last_selected_cell = null;
  this.selected_field_id = null;

  this.container                = document.createElement('div');
  this.container.className      = 'wf_calendar';
  this.container.id             = 'wf_calendar';
  this.container.style.display  = "none";

  document.body.appendChild(this.container);
}

Wf.Calendar.prototype = {
  show: function(fld_id, trigger, show_time) {
    if (this.selected_field_id == fld_id) {
      this.hide();
      return;
    }

    this.trigger = trigger;
		
    var form_hash = {};
		form_hash["wf_calendar_selected_date"] = Wf.value(fld_id);
    form_hash["wf_calendar_show_time"] = show_time;
		
    this.selected_field_id = fld_id;
    Wf.Utils.update('wf_calendar', '/wf/calendar', {
      parameters: form_hash,
      onComplete: function(transport) {
          var trigger_position = Wf.Utils.cumulativeOffset(wfCalendar.trigger);
          var calendar_container = Wf.element("wf_calendar");
          calendar_container.style.left = (trigger_position[0] - 237) + "px";
          calendar_container.style.top = trigger_position[1] + "px";
          calendar_container.style.width = "230px";
          Wf.Effects.appear("wf_calendar");
      } 
    });
  },
  selectDate: function(fld_id, trigger){
    this.show(fld_id, trigger, false);
  },
  selectDateTime: function(fld_id, trigger){
    this.show(fld_id, trigger, true);
  },
	changeMode: function(mode) {
    var form_hash = Wf.Utils.serializeForm('wf_calendar_form');
    form_hash["wf_calendar_mode"] = mode;
		
    if (mode == 'annual')
      form_hash["wf_calendar_start_date"] = Wf.value("wf_calendar_year") + "-01-01";
		
    Wf.Utils.update('wf_calendar', '/wf/calendar', {
      parameters: form_hash,
      onComplete: function(transport) {
          var trigger_position = Wf.Utils.cumulativeOffset(wfCalendar.trigger);
          var width = (mode=='annual' ? 760 : 400);
          var calendar_container = Wf.element("wf_calendar");
          calendar_container.style.left = (trigger_position[0] - width - 7) + "px";
          calendar_container.style.top = trigger_position[1] + "px";
          calendar_container.style.width = width + "px";
      } 
    });
	},
	goToStartDate: function(start_date) {
    var form_hash = Wf.Utils.serializeForm('wf_calendar_form');
		if (start_date == '')
      form_hash["wf_calendar_start_date"] = Wf.value("wf_calendar_year") + "-" + Wf.value("wf_calendar_month") + "-01";
		else
			form_hash["wf_calendar_start_date"] = start_date;
		
	  Wf.Utils.update('wf_calendar', '/wf/calendar', {
	    parameters: form_hash
	  });
	},
	setSelectedFieldValue: function(value) {
	  if (this.selected_field_id==null || Wf.element(this.selected_field_id)==null)
	    return;
	  Wf.element(this.selected_field_id).value = value;
		wfFilter.fieldChanged(this.selected_field_id);
	  this.selected_field_id = null;
	},
	selectDateValue: function(elem_id, date) {
		if (this.last_selected_cell)
		  Wf.Utils.removeClassName(Wf.element(this.last_selected_cell), "selected");
			
	  Wf.Utils.addClassName(Wf.element(elem_id), 'selected'); 
		this.last_selected_cell = elem_id;
		
	  Wf.element("wf_calendar_selected_date").value = date;
	},
	setDate: function() {
	  this.setSelectedFieldValue(Wf.value("wf_calendar_selected_date"));
    this.hide();
	},
	prepandZero: function(val) {
	  if (parseInt(val) >= 10) 
	    return val;
	    
	  return ("0" + val);
	},
	setDateTime: function() {
	  var val = Wf.value("wf_calendar_selected_date");
	  val += " " + this.prepandZero(Wf.value("wf_calendar_hour"));
	  val += ":" + this.prepandZero(Wf.value("wf_calendar_minute"));
	  val += ":" + this.prepandZero(Wf.value("wf_calendar_second"));
	  
	  this.setSelectedFieldValue(val);
	  this.hide();
  },
	hide: function() {
		this.selected_field_id = null;
    Wf.Effects.fade("wf_calendar");
	}
};

/****************************************************************************
**** Filter Exporter
****************************************************************************/

Wf.Exporter = function(options) {
  this.options = options || {};
	
  this.container                = document.createElement('div');
  this.container.className      = 'wf_exporter';
  this.container.id             = 'wf_exporter';
  this.container.style.display  = "none";

  document.body.appendChild(this.container);
}

Wf.Exporter.prototype = {
	show: function (trigger) {
	  Wf.Utils.update('wf_exporter', '/wf/exporter', {
	    parameters: Wf.Utils.serializeForm('wf_form'),
	    onComplete: function(transport) {
          var trigger_position = Wf.Utils.cumulativeOffset(trigger);
          var exporter_container = Wf.element("wf_exporter");
          exporter_container.style.left = (trigger_position[0] - 240) + "px";
          exporter_container.style.top = trigger_position[1] + "px";
				  Wf.Effects.appear("wf_exporter");
	    } 
	  });
  },
  hide: function() {
    Wf.Effects.fade("wf_exporter");
  },
	selectAllFields: function (fld) {
	  var i = 0;
	  var chkFld = Wf.element("wf_fld_chk_" + i);
	  while (chkFld != null) {
	    chkFld.checked = fld.checked;
	    i++;
	    chkFld = Wf.element("wf_fld_chk_" + i);
	  }   
	  this.updateExportFields();
	},
	selectField: function (fld) {
	  if (!fld.checked) {
	    Wf.element("wf_fld_all").checked = false;
	  }
	  this.updateExportFields();
	},
	updateExportFields: function () {
	  var i = 0;
	  var chkFld = Wf.element("wf_fld_chk_" + i);
	  var fields = "";
	  while (chkFld != null) {
	    if (chkFld.checked) {
	      if (fields != "") fields += ",";
	      fields += Wf.value("wf_fld_name_" + i);
	    }
	    i++;
	    chkFld = Wf.element("wf_fld_chk_" + i);
	  }   
	
	  Wf.element("wf_export_fields").value = fields;
	}, 
  exportFilter: function() {
		if (wfFilter.original_form_action == "")
      wfFilter.original_form_action = Wf.element('wf_form').action;
			
    this.updateExportFields();
		
    if (Wf.value("wf_export_fields") == "") {
      alert("Please select st least one field to export");
      return;
    }

    if (Wf.value('wf_export_format_selector') == "-1") {
      alert("Please select an export format");
      return;
    }

    Wf.element('wf_export_format').value = Wf.value('wf_export_format_selector'); 
    Wf.element('wf_form').action = '/wf/exporter/export';
    Wf.submit('wf_form');
  }
};



/****************************************************************************
**** Utilities
****************************************************************************/

Wf.Utils = {

  addEvent: function(elm, evType, fn, useCapture) {
    useCapture = useCapture || false;
    if (elm.addEventListener) {
      elm.addEventListener(evType, fn, useCapture);
      return true;
    } else if (elm.attachEvent) {
      var r = elm.attachEvent('on' + evType, fn);
      return r;
    } else {
      elm['on' + evType] = fn;
    }
  },

  toQueryParams: function (obj) { 
    if (typeof obj == 'undefined' || obj == null) return "";
    if (typeof obj == 'string') return obj;      
    
    var qs = [];
    for(p in obj) {
        qs.push(p + "=" + encodeURIComponent(obj[p]))
    }
    return qs.join("&")
  },
  
  serializeForm: function(form) { 
    var els = Wf.element(form).elements; 
    var form_obj = {} 
    for(i=0; i < els.length; i++) {
      if (els[i].type == 'checkbox' && !els[i].checked) continue;
      if (els[i].type == 'radio' && !els[i].checked) continue;
      form_obj[els[i].name] = els[i].value;
    } 
    return form_obj; 
  }, 

  getRequest: function() {
    var factories = [
      function() { return new ActiveXObject("Msxml2.XMLHTTP"); },
      function() { return new XMLHttpRequest(); },
      function() { return new ActiveXObject("Microsoft.XMLHTTP"); }
    ];
    for(var i = 0; i < factories.length; i++) {
      try {
        var request = factories[i]();
        if (request != null)  return request;
      } catch(e) {continue;}
    }
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = Wf.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }
    var request = this.getRequest();
    
    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if(options.onSuccess) options.onSuccess(request);
          if(options.onComplete) options.onComplete(request);
          if(options.evalScripts) self.evalScripts(request.responseText);
        } else {
          if(options.onFailure) options.onFailure(request)
          if(options.onComplete) options.onComplete(request)
        }
      }
    }
    
    request.open(options.method, url, true);
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  update: function(element_id, url, options) {
    options.onSuccess = function(response) {
        Wf.element(element_id).innerHTML = response.responseText;
    };
    Wf.Utils.ajax(url, options);
  },
  
  evalScripts: function(html){
    var script_re = '<script[^>]*>([\\S\\s]*?)<\/script>';
    var matchAll = new RegExp(script_re, 'img');
    var matchOne = new RegExp(script_re, 'im');
    var matches = html.match(matchAll) || [];
    for(var i=0,l=matches.length;i<l;i++){
      var script = (matches[i].match(matchOne) || ['', ''])[1];
      // console.info(script)
      // alert(script);
      eval(script);
    }
  },

  hasClassName: function(el, cls){
    var exp = new RegExp("(^|\\s)"+cls+"($|\\s)");
    return (el.className && exp.test(el.className))?true:false;
  },

  addClassName: function(el, cls) {
    if (!Wf.Utils.hasClassName(el,cls)) el.className += " " + cls;
  },
  
  removeClassName: function(el,cls) {
    if (Wf.Utils.hasClassName(el,cls)) {
      var reg = new RegExp('(\\s|^)'+cls+'(\\s|$)');
      el.className=el.className.replace(reg, ' ');
    }
  },

  findElement: function(e,selector,el) {
    var event = e || window.event;
    var target = el || event.target || event.srcElement;
    if(target == document.body) return null;
    var condition = (selector.match(/^\./)) ? this.hasClassName(target,selector.replace(/^\./,'')) : (target.tagName.toLowerCase() == selector.toLowerCase());
    if(condition) {
      return target;
    } else {
      return this.findElement(e,selector,target.parentNode);
    }
  },

  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  }
	
}

/****************************************************************************
**** Initialization
****************************************************************************/

var wfFilter = null;
var wfCalendar = null;
var wfExporter = null;

function initializeWillFilter() { 
  var setup = function() { 
    wfFilter = new Wf.Filter(); 
    wfCalendar = new Wf.Calendar(); 
    wfExporter = new Wf.Exporter(); 
  } 
	
  Wf.Utils.addEvent(window,'load',setup);
}
