




if (window && !window.InflectionJS)
{
    window.InflectionJS = null;
}


InflectionJS =
{
    
    uncountable_words: [
        'equipment', 'information', 'rice', 'money', 'species', 'series',
        'fish', 'sheep', 'moose', 'deer', 'news'
    ],

    
    plural_rules: [
        [new RegExp('(m)an$', 'gi'),                 '$1en'],
        [new RegExp('(pe)rson$', 'gi'),              '$1ople'],
        [new RegExp('(child)$', 'gi'),               '$1ren'],
        [new RegExp('^(ox)$', 'gi'),                 '$1en'],
        [new RegExp('(ax|test)is$', 'gi'),           '$1es'],
        [new RegExp('(octop|vir)us$', 'gi'),         '$1i'],
        [new RegExp('(alias|status)$', 'gi'),        '$1es'],
        [new RegExp('(bu)s$', 'gi'),                 '$1ses'],
        [new RegExp('(buffal|tomat|potat)o$', 'gi'), '$1oes'],
        [new RegExp('([ti])um$', 'gi'),              '$1a'],
        [new RegExp('sis$', 'gi'),                   'ses'],
        [new RegExp('(?:([^f])fe|([lr])f)$', 'gi'),  '$1$2ves'],
        [new RegExp('(hive)$', 'gi'),                '$1s'],
        [new RegExp('([^aeiouy]|qu)y$', 'gi'),       '$1ies'],
        [new RegExp('(x|ch|ss|sh)$', 'gi'),          '$1es'],
        [new RegExp('(matr|vert|ind)ix|ex$', 'gi'),  '$1ices'],
        [new RegExp('([m|l])ouse$', 'gi'),           '$1ice'],
        [new RegExp('(quiz)$', 'gi'),                '$1zes'],
        [new RegExp('s$', 'gi'),                     's'],
        [new RegExp('$', 'gi'),                      's']
    ],

    
    singular_rules: [
        [new RegExp('(m)en$', 'gi'),                                                       '$1an'],
        [new RegExp('(pe)ople$', 'gi'),                                                    '$1rson'],
        [new RegExp('(child)ren$', 'gi'),                                                  '$1'],
        [new RegExp('([ti])a$', 'gi'),                                                     '$1um'],
        [new RegExp('((a)naly|(b)a|(d)iagno|(p)arenthe|(p)rogno|(s)ynop|(t)he)ses$','gi'), '$1$2sis'],
        [new RegExp('(hive)s$', 'gi'),                                                     '$1'],
        [new RegExp('(tive)s$', 'gi'),                                                     '$1'],
        [new RegExp('(curve)s$', 'gi'),                                                    '$1'],
        [new RegExp('([lr])ves$', 'gi'),                                                   '$1f'],
        [new RegExp('([^fo])ves$', 'gi'),                                                  '$1fe'],
        [new RegExp('([^aeiouy]|qu)ies$', 'gi'),                                           '$1y'],
        [new RegExp('(s)eries$', 'gi'),                                                    '$1eries'],
        [new RegExp('(m)ovies$', 'gi'),                                                    '$1ovie'],
        [new RegExp('(x|ch|ss|sh)es$', 'gi'),                                              '$1'],
        [new RegExp('([m|l])ice$', 'gi'),                                                  '$1ouse'],
        [new RegExp('(bus)es$', 'gi'),                                                     '$1'],
        [new RegExp('(o)es$', 'gi'),                                                       '$1'],
        [new RegExp('(shoe)s$', 'gi'),                                                     '$1'],
        [new RegExp('(cris|ax|test)es$', 'gi'),                                            '$1is'],
        [new RegExp('(octop|vir)i$', 'gi'),                                                '$1us'],
        [new RegExp('(alias|status)es$', 'gi'),                                            '$1'],
        [new RegExp('^(ox)en', 'gi'),                                                      '$1'],
        [new RegExp('(vert|ind)ices$', 'gi'),                                              '$1ex'],
        [new RegExp('(matr)ices$', 'gi'),                                                  '$1ix'],
        [new RegExp('(quiz)zes$', 'gi'),                                                   '$1'],
        [new RegExp('s$', 'gi'),                                                           '']
    ],

    
    non_titlecased_words: [
        'and', 'or', 'nor', 'a', 'an', 'the', 'so', 'but', 'to', 'of', 'at',
        'by', 'from', 'into', 'on', 'onto', 'off', 'out', 'in', 'over',
        'with', 'for'
    ],

    
    id_suffix: new RegExp('(_ids|_id)$', 'g'),
    underbar: new RegExp('_', 'g'),
    space_or_underbar: new RegExp('[\ _]', 'g'),
    uppercase: new RegExp('([A-Z])', 'g'),
    underbar_prefix: new RegExp('^_'),
    
    
    apply_rules: function(str, rules, skip, override)
    {
        if (override)
        {
            str = override;
        }
        else
        {
            var ignore = (skip.indexOf(str.toLowerCase()) > -1);
            if (!ignore)
            {
                for (var x = 0; x < rules.length; x++)
                {
                    if (str.match(rules[x][0]))
                    {
                        str = str.replace(rules[x][0], rules[x][1]);
                        break;
                    }
                }
            }
        }
        return str;
    }
};


if (!Array.prototype.indexOf)
{
    Array.prototype.indexOf = function(item, fromIndex, compareFunc)
    {
        if (!fromIndex)
        {
            fromIndex = -1;
        }
        var index = -1;
        for (var i = fromIndex; i < this.length; i++)
        {
            if (this[i] === item || compareFunc && compareFunc(this[i], item))
            {
                index = i;
                break;
            }
        }
        return index;
    };
}


if (!String.prototype._uncountable_words)
{
    String.prototype._uncountable_words = InflectionJS.uncountable_words;
}


if (!String.prototype._plural_rules)
{
    String.prototype._plural_rules = InflectionJS.plural_rules;
}


if (!String.prototype._singular_rules)
{
    String.prototype._singular_rules = InflectionJS.singular_rules;
}


if (!String.prototype._non_titlecased_words)
{
    String.prototype._non_titlecased_words = InflectionJS.non_titlecased_words;
}


if (!String.prototype.pluralize)
{
    String.prototype.pluralize = function(plural)
    {
        return InflectionJS.apply_rules(
            this,
            this._plural_rules,
            this._uncountable_words,
            plural
        );
    };
}


if (!String.prototype.singularize)
{
    String.prototype.singularize = function(singular)
    {
        return InflectionJS.apply_rules(
            this,
            this._singular_rules,
            this._uncountable_words,
            singular
        );
    };
}


var MD5 = function (string) {
 
  function RotateLeft(lValue, iShiftBits) {
    return (lValue<<iShiftBits) | (lValue>>>(32-iShiftBits));
  }
 
  function AddUnsigned(lX,lY) {
    var lX4,lY4,lX8,lY8,lResult;
    lX8 = (lX & 0x80000000);
    lY8 = (lY & 0x80000000);
    lX4 = (lX & 0x40000000);
    lY4 = (lY & 0x40000000);
    lResult = (lX & 0x3FFFFFFF)+(lY & 0x3FFFFFFF);
    if (lX4 & lY4) {
      return (lResult ^ 0x80000000 ^ lX8 ^ lY8);
    }
    if (lX4 | lY4) {
      if (lResult & 0x40000000) {
        return (lResult ^ 0xC0000000 ^ lX8 ^ lY8);
      } else {
        return (lResult ^ 0x40000000 ^ lX8 ^ lY8);
      }
    } else {
      return (lResult ^ lX8 ^ lY8);
    }
  }
 
  function F(x,y,z) { return (x & y) | ((~x) & z); }
  function G(x,y,z) { return (x & z) | (y & (~z)); }
  function H(x,y,z) { return (x ^ y ^ z); }
  function I(x,y,z) { return (y ^ (x | (~z))); }
 
  function FF(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(F(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function GG(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(G(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function HH(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(H(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function II(a,b,c,d,x,s,ac) {
    a = AddUnsigned(a, AddUnsigned(AddUnsigned(I(b, c, d), x), ac));
    return AddUnsigned(RotateLeft(a, s), b);
  };
 
  function ConvertToWordArray(string) {
    var lWordCount;
    var lMessageLength = string.length;
    var lNumberOfWords_temp1=lMessageLength + 8;
    var lNumberOfWords_temp2=(lNumberOfWords_temp1-(lNumberOfWords_temp1 % 64))/64;
    var lNumberOfWords = (lNumberOfWords_temp2+1)*16;
    var lWordArray=Array(lNumberOfWords-1);
    var lBytePosition = 0;
    var lByteCount = 0;
    while ( lByteCount < lMessageLength ) {
      lWordCount = (lByteCount-(lByteCount % 4))/4;
      lBytePosition = (lByteCount % 4)*8;
      lWordArray[lWordCount] = (lWordArray[lWordCount] | (string.charCodeAt(lByteCount)<<lBytePosition));
      lByteCount++;
    }
    lWordCount = (lByteCount-(lByteCount % 4))/4;
    lBytePosition = (lByteCount % 4)*8;
    lWordArray[lWordCount] = lWordArray[lWordCount] | (0x80<<lBytePosition);
    lWordArray[lNumberOfWords-2] = lMessageLength<<3;
    lWordArray[lNumberOfWords-1] = lMessageLength>>>29;
    return lWordArray;
  };
 
  function WordToHex(lValue) {
    var WordToHexValue="",WordToHexValue_temp="",lByte,lCount;
    for (lCount = 0;lCount<=3;lCount++) {
      lByte = (lValue>>>(lCount*8)) & 255;
      WordToHexValue_temp = "0" + lByte.toString(16);
      WordToHexValue = WordToHexValue + WordToHexValue_temp.substr(WordToHexValue_temp.length-2,2);
    }
    return WordToHexValue;
  };
 
  function Utf8Encode(string) {
    string = string.replace(/\r\n/g,"\n");
    var utftext = "";
 
    for (var n = 0; n < string.length; n++) {
 
      var c = string.charCodeAt(n);
 
      if (c < 128) {
        utftext += String.fromCharCode(c);
      }
      else if((c > 127) && (c < 2048)) {
        utftext += String.fromCharCode((c >> 6) | 192);
        utftext += String.fromCharCode((c & 63) | 128);
      }
      else {
        utftext += String.fromCharCode((c >> 12) | 224);
        utftext += String.fromCharCode(((c >> 6) & 63) | 128);
        utftext += String.fromCharCode((c & 63) | 128);
      }
 
    }
 
    return utftext;
  };
 
  var x=Array();
  var k,AA,BB,CC,DD,a,b,c,d;
  var S11=7, S12=12, S13=17, S14=22;
  var S21=5, S22=9 , S23=14, S24=20;
  var S31=4, S32=11, S33=16, S34=23;
  var S41=6, S42=10, S43=15, S44=21;
 
  string = Utf8Encode(string);
 
  x = ConvertToWordArray(string);
 
  a = 0x67452301; b = 0xEFCDAB89; c = 0x98BADCFE; d = 0x10325476;
 
  for (k=0;k<x.length;k+=16) {
    AA=a; BB=b; CC=c; DD=d;
    a=FF(a,b,c,d,x[k+0], S11,0xD76AA478);
    d=FF(d,a,b,c,x[k+1], S12,0xE8C7B756);
    c=FF(c,d,a,b,x[k+2], S13,0x242070DB);
    b=FF(b,c,d,a,x[k+3], S14,0xC1BDCEEE);
    a=FF(a,b,c,d,x[k+4], S11,0xF57C0FAF);
    d=FF(d,a,b,c,x[k+5], S12,0x4787C62A);
    c=FF(c,d,a,b,x[k+6], S13,0xA8304613);
    b=FF(b,c,d,a,x[k+7], S14,0xFD469501);
    a=FF(a,b,c,d,x[k+8], S11,0x698098D8);
    d=FF(d,a,b,c,x[k+9], S12,0x8B44F7AF);
    c=FF(c,d,a,b,x[k+10],S13,0xFFFF5BB1);
    b=FF(b,c,d,a,x[k+11],S14,0x895CD7BE);
    a=FF(a,b,c,d,x[k+12],S11,0x6B901122);
    d=FF(d,a,b,c,x[k+13],S12,0xFD987193);
    c=FF(c,d,a,b,x[k+14],S13,0xA679438E);
    b=FF(b,c,d,a,x[k+15],S14,0x49B40821);
    a=GG(a,b,c,d,x[k+1], S21,0xF61E2562);
    d=GG(d,a,b,c,x[k+6], S22,0xC040B340);
    c=GG(c,d,a,b,x[k+11],S23,0x265E5A51);
    b=GG(b,c,d,a,x[k+0], S24,0xE9B6C7AA);
    a=GG(a,b,c,d,x[k+5], S21,0xD62F105D);
    d=GG(d,a,b,c,x[k+10],S22,0x2441453);
    c=GG(c,d,a,b,x[k+15],S23,0xD8A1E681);
    b=GG(b,c,d,a,x[k+4], S24,0xE7D3FBC8);
    a=GG(a,b,c,d,x[k+9], S21,0x21E1CDE6);
    d=GG(d,a,b,c,x[k+14],S22,0xC33707D6);
    c=GG(c,d,a,b,x[k+3], S23,0xF4D50D87);
    b=GG(b,c,d,a,x[k+8], S24,0x455A14ED);
    a=GG(a,b,c,d,x[k+13],S21,0xA9E3E905);
    d=GG(d,a,b,c,x[k+2], S22,0xFCEFA3F8);
    c=GG(c,d,a,b,x[k+7], S23,0x676F02D9);
    b=GG(b,c,d,a,x[k+12],S24,0x8D2A4C8A);
    a=HH(a,b,c,d,x[k+5], S31,0xFFFA3942);
    d=HH(d,a,b,c,x[k+8], S32,0x8771F681);
    c=HH(c,d,a,b,x[k+11],S33,0x6D9D6122);
    b=HH(b,c,d,a,x[k+14],S34,0xFDE5380C);
    a=HH(a,b,c,d,x[k+1], S31,0xA4BEEA44);
    d=HH(d,a,b,c,x[k+4], S32,0x4BDECFA9);
    c=HH(c,d,a,b,x[k+7], S33,0xF6BB4B60);
    b=HH(b,c,d,a,x[k+10],S34,0xBEBFBC70);
    a=HH(a,b,c,d,x[k+13],S31,0x289B7EC6);
    d=HH(d,a,b,c,x[k+0], S32,0xEAA127FA);
    c=HH(c,d,a,b,x[k+3], S33,0xD4EF3085);
    b=HH(b,c,d,a,x[k+6], S34,0x4881D05);
    a=HH(a,b,c,d,x[k+9], S31,0xD9D4D039);
    d=HH(d,a,b,c,x[k+12],S32,0xE6DB99E5);
    c=HH(c,d,a,b,x[k+15],S33,0x1FA27CF8);
    b=HH(b,c,d,a,x[k+2], S34,0xC4AC5665);
    a=II(a,b,c,d,x[k+0], S41,0xF4292244);
    d=II(d,a,b,c,x[k+7], S42,0x432AFF97);
    c=II(c,d,a,b,x[k+14],S43,0xAB9423A7);
    b=II(b,c,d,a,x[k+5], S44,0xFC93A039);
    a=II(a,b,c,d,x[k+12],S41,0x655B59C3);
    d=II(d,a,b,c,x[k+3], S42,0x8F0CCC92);
    c=II(c,d,a,b,x[k+10],S43,0xFFEFF47D);
    b=II(b,c,d,a,x[k+1], S44,0x85845DD1);
    a=II(a,b,c,d,x[k+8], S41,0x6FA87E4F);
    d=II(d,a,b,c,x[k+15],S42,0xFE2CE6E0);
    c=II(c,d,a,b,x[k+6], S43,0xA3014314);
    b=II(b,c,d,a,x[k+13],S44,0x4E0811A1);
    a=II(a,b,c,d,x[k+4], S41,0xF7537E82);
    d=II(d,a,b,c,x[k+11],S42,0xBD3AF235);
    c=II(c,d,a,b,x[k+2], S43,0x2AD7D2BB);
    b=II(b,c,d,a,x[k+9], S44,0xEB86D391);
    a=AddUnsigned(a,AA);
    b=AddUnsigned(b,BB);
    c=AddUnsigned(c,CC);
    d=AddUnsigned(d,DD);
  }
 
  var temp = WordToHex(a)+WordToHex(b)+WordToHex(c)+WordToHex(d);
 
  return temp.toLowerCase();
}
shortcut = {
  'all_shortcuts':{},//All the shortcuts are stored in this array
  'add': function(shortcut_combination,callback,opt) {
    //Provide a set of default options
    var default_options = {
      'type':'keydown',
      'propagate':false,
      'disable_in_input':false,
      'target':document,
      'keycode':false
    }
    if(!opt) opt = default_options;
    else {
      for(var dfo in default_options) {
        if(typeof opt[dfo] == 'undefined') opt[dfo] = default_options[dfo];
      }
    }

    var ele = opt.target;
    if(typeof opt.target == 'string') ele = document.getElementById(opt.target);
    var ths = this;
    shortcut_combination = shortcut_combination.toLowerCase();

    //The function to be called at keypress
    var func = function(e) {
      e = e || window.event;
      
      if(opt['disable_in_input']) { //Don't enable shortcut keys in Input, Textarea fields
        var element;
        if(e.target) element=e.target;
        else if(e.srcElement) element=e.srcElement;
        if(element.nodeType==3) element=element.parentNode;

        if(element.tagName == 'INPUT' || element.tagName == 'TEXTAREA') return;
      }
  
      //Find Which key is pressed
      if (e.keyCode) code = e.keyCode;
      else if (e.which) code = e.which;
      var character = String.fromCharCode(code).toLowerCase();
      
      if(code == 188) character=","; //If the user presses , when the type is onkeydown
      if(code == 190) character="."; //If the user presses , when the type is onkeydown

      var keys = shortcut_combination.split("+");
      //Key Pressed - counts the number of valid keypresses - if it is same as the number of keys, the shortcut function is invoked
      var kp = 0;
      
      //Work around for stupid Shift key bug created by using lowercase - as a result the shift+num combination was broken
      var shift_nums = {
        "`":"~",
        "1":"!",
        "2":"@",
        "3":"#",
        "4":"$",
        "5":"%",
        "6":"^",
        "7":"&",
        "8":"*",
        "9":"(",
        "0":")",
        "-":"_",
        "=":"+",
        ";":":",
        "'":"\"",
        ",":"<",
        ".":">",
        "/":"?",
        "\\":"|"
      }
      //Special Keys - and their codes
      var special_keys = {
        'esc':27,
        'escape':27,
        'tab':9,
        'space':32,
        'return':13,
        'enter':13,
        'backspace':8,
  
        'scrolllock':145,
        'scroll_lock':145,
        'scroll':145,
        'capslock':20,
        'caps_lock':20,
        'caps':20,
        'numlock':144,
        'num_lock':144,
        'num':144,
        
        'pause':19,
        'break':19,
        
        'insert':45,
        'home':36,
        'delete':46,
        'end':35,
        
        'pageup':33,
        'page_up':33,
        'pu':33,
  
        'pagedown':34,
        'page_down':34,
        'pd':34,
  
        'left':37,
        'up':38,
        'right':39,
        'down':40,
  
        'f1':112,
        'f2':113,
        'f3':114,
        'f4':115,
        'f5':116,
        'f6':117,
        'f7':118,
        'f8':119,
        'f9':120,
        'f10':121,
        'f11':122,
        'f12':123
      }
  
      var modifiers = { 
        shift: { wanted:false, pressed:false},
        ctrl : { wanted:false, pressed:false},
        alt  : { wanted:false, pressed:false},
        meta : { wanted:false, pressed:false} //Meta is Mac specific
      };
                        
      if(e.ctrlKey) modifiers.ctrl.pressed = true;
      if(e.shiftKey)  modifiers.shift.pressed = true;
      if(e.altKey)  modifiers.alt.pressed = true;
      if(e.metaKey)   modifiers.meta.pressed = true;
                        
      for(var i=0; k=keys[i],i<keys.length; i++) {
        //Modifiers
        if(k == 'ctrl' || k == 'control') {
          kp++;
          modifiers.ctrl.wanted = true;

        } else if(k == 'shift') {
          kp++;
          modifiers.shift.wanted = true;

        } else if(k == 'alt') {
          kp++;
          modifiers.alt.wanted = true;
        } else if(k == 'meta') {
          kp++;
          modifiers.meta.wanted = true;
        } else if(k.length > 1) { //If it is a special key
          if(special_keys[k] == code) kp++;
          
        } else if(opt['keycode']) {
          if(opt['keycode'] == code) kp++;

        } else { //The special keys did not match
          if(character == k) kp++;
          else {
            if(shift_nums[character] && e.shiftKey) { //Stupid Shift key bug created by using lowercase
              character = shift_nums[character]; 
              if(character == k) kp++;
            }
          }
        }
      }
      
      if(kp == keys.length && 
            modifiers.ctrl.pressed == modifiers.ctrl.wanted &&
            modifiers.shift.pressed == modifiers.shift.wanted &&
            modifiers.alt.pressed == modifiers.alt.wanted &&
            modifiers.meta.pressed == modifiers.meta.wanted) {
        callback(e);
  
        if(!opt['propagate']) { //Stop the event
          //e.cancelBubble is supported by IE - this will kill the bubbling process.
          e.cancelBubble = true;
          e.returnValue = false;
  
          //e.stopPropagation works in Firefox.
          if (e.stopPropagation) {
            e.stopPropagation();
            e.preventDefault();
          }
          return false;
        }
      }
    }
    this.all_shortcuts[shortcut_combination] = {
      'callback':func, 
      'target':ele, 
      'event': opt['type']
    };
    //Attach the function with the event
    if(ele.addEventListener) ele.addEventListener(opt['type'], func, false);
    else if(ele.attachEvent) ele.attachEvent('on'+opt['type'], func);
    else ele['on'+opt['type']] = func;
  },

  //Remove the shortcut - just specify the shortcut and I will remove the binding
  'remove':function(shortcut_combination) {
    shortcut_combination = shortcut_combination.toLowerCase();
    var binding = this.all_shortcuts[shortcut_combination];
    delete(this.all_shortcuts[shortcut_combination])
    if(!binding) return;
    var type = binding['event'];
    var ele = binding['target'];
    var callback = binding['callback'];

    if(ele.detachEvent) ele.detachEvent('on'+type, callback);
    else if(ele.removeEventListener) ele.removeEventListener(type, callback, false);
    else ele['on'+type] = false;
  }
}
var VKI_attach, VKI_close;
var VKI_default_layout = VKI_default_layout || "US International";
var VKI_default_keyboard_image = VKI_default_keyboard_image || "";

(function() {
  var self = this;

  this.VKI_version = "1.49";
  this.VKI_showVersion = true;
  this.VKI_target = false;
  this.VKI_shift = this.VKI_shiftlock = false;
  this.VKI_altgr = this.VKI_altgrlock = false;
  this.VKI_dead = false;
  this.VKI_deadBox = true; // Show the dead keys checkbox
  this.VKI_deadkeysOn = false;  // Turn dead keys on by default
  this.VKI_numberPad = true;  // Allow user to open and close the number pad
  this.VKI_numberPadOn = false;  // Show number pad by default
  this.VKI_kts = this.VKI_kt = VKI_default_layout;  // Default keyboard layout
  this.VKI_langAdapt = true;  // Use lang attribute of input to select keyboard
  this.VKI_size = 2;  // Default keyboard size (1-5)
  this.VKI_sizeAdj = true;  // Allow user to adjust keyboard size
  this.VKI_clearPasswords = false;  // Clear password fields on focus
  this.VKI_imageURI = VKI_default_keyboard_image;  // If empty string, use imageless mode
  this.VKI_clickless = 0;  // 0 = disabled, > 0 = delay in ms
  this.VKI_activeTab = 0;  // Tab moves to next: 1 = element, 2 = keyboard enabled element
  this.VKI_enterSubmit = true;  // Submit forms when Enter is pressed
  this.VKI_keyCenter = 3;

  this.VKI_isIE = false;
  this.VKI_isIE6 = false;
  this.VKI_isIElt8 = false;
  this.VKI_isWebKit = RegExp("KHTML").test(navigator.userAgent);
  this.VKI_isOpera = RegExp("Opera").test(navigator.userAgent);
  this.VKI_isMoz = (!this.VKI_isWebKit && navigator.product == "Gecko");

  
  this.VKI_i18n = {
    '00': "Display Number Pad",
    '01': "Display virtual keyboard interface",
    '02': "Select keyboard layout",
    '03': "Dead keys",
    '04': "On",
    '05': "Off",
    '06': "Close the keyboard",
    '07': "Clear",
    '08': "Clear this input",
    '09': "Version",
    '10': "Decrease keyboard size",
    '11': "Increase keyboard size"
  };


  
  this.VKI_layout = {};

  // - Lay out each keyboard in rows of sub-arrays.  Each sub-array
  //   represents one key.
  //
  // - Each sub-array consists of four slots described as follows:
  //     example: ["a", "A", "\u00e1", "\u00c1"]
  //
  //          a) Normal character
  //          A) Character + Shift/Caps
  //     \u00e1) Character + Alt/AltGr/AltLk
  //     \u00c1) Character + Shift/Caps + Alt/AltGr/AltLk
  //
  //   You may include sub-arrays which are fewer than four slots.
  //   In these cases, the missing slots will be blanked when the
  //   corresponding modifier key (Shift or AltGr) is pressed.
  //
  // - If the second slot of a sub-array matches one of the following
  //   strings:
  //     "Tab", "Caps", "Shift", "Enter", "Bksp",
  //     "Alt" OR "AltGr", "AltLk"
  //   then the function of the key will be the following,
  //   respectively:
  //     - Insert a tab
  //     - Toggle Caps Lock (technically a Shift Lock)
  //     - Next entered character will be the shifted character
  //     - Insert a newline (textarea), or close the keyboard
  //     - Delete the previous character
  //     - Next entered character will be the alternate character
  //     - Toggle Alt/AltGr Lock
  //
  //   The first slot of this sub-array will be the text to display
  //   on the corresponding key.  This allows for easy localisation
  //   of key names.
  //
  // - Layout dead keys (diacritic + letter) should be added as
  //   property/value pairs of objects with hash keys equal to the
  //   diacritic.  See the "this.VKI_deadkey" object below the layout
  //   definitions.  In each property/value pair, the value is what
  //   the diacritic would change the property name to.
  //
  // - Note that any characters beyond the normal ASCII set should be
  //   entered in escaped Unicode format.  (eg \u00a3 = Pound symbol)
  //   You can find Unicode values for characters here:
  //     http://unicode.org/charts/
  //
  // - To remove a keyboard, just delete it, or comment it out of the
  //   source code. If you decide to remove the US International
  //   keyboard layout, make sure you change the default layout
  //   (this.VKI_kt) above so it references an existing layout.

  this.VKI_layout['\u0627\u0644\u0639\u0631\u0628\u064a\u0629'] = {
    'name': "Arabic", 'keys': [
      [["\u0630", "\u0651 "], ["1", "!", "\u00a1", "\u00b9"], ["2", "@", "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00a4", "\u00a3"], ["5", "%", "\u20ac"], ["6", "^", "\u00bc"], ["7", "&", "\u00bd"], ["8", "*", "\u00be"], ["9", "(", "\u2018"], ["0", ")", "\u2019"], ["-", "_", "\u00a5"], ["=", "+", "\u00d7", "\u00f7"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0636", "\u064e"], ["\u0635", "\u064b"], ["\u062b", "\u064f"], ["\u0642", "\u064c"], ["\u0641", "\u0644"], ["\u063a", "\u0625"], ["\u0639", "\u2018"], ["\u0647", "\u00f7"], ["\u062e", "\u00d7"], ["\u062d", "\u061b"], ["\u062c", "<"], ["\u062f", ">"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u0634", "\u0650"], ["\u0633", "\u064d"], ["\u064a", "]"], ["\u0628", "["], ["\u0644", "\u0644"], ["\u0627", "\u0623"], ["\u062a", "\u0640"], ["\u0646", "\u060c"], ["\u0645", "/"], ["\u0643", ":"], ["\u0637", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0626", "~"], ["\u0621", "\u0652"], ["\u0624", "}"], ["\u0631", "{"], ["\u0644", "\u0644"], ["\u0649", "\u0622"], ["\u0629", "\u2019"], ["\u0648", ","], ["\u0632", "."], ["\u0638", "\u061f"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["ar"] };

  this.VKI_layout['\u0985\u09b8\u09ae\u09c0\u09df\u09be'] = {
    'name': "Assamese", 'keys': [
      [["+", "?"], ["\u09E7", "{", "\u09E7"], ["\u09E8", "}", "\u09E8"], ["\u09E9", "\u09CD\u09F0", "\u09E9"], ["\u09EA", "\u09F0\u09CD", "\u09EA"], ["\u09EB", "\u099C\u09CD\u09F0", "\u09EB"], ["\u09EC", "\u0995\u09CD\u09B7", "\u09EC"], ["\u09ED", "\u0995\u09CD\u09F0", "\u09ED"], ["\u09EE", "\u09B6\u09CD\u09F0", "\u09EE"], ["\u09EF", "(", "\u09EF"], ["\u09E6", ")", "\u09E6"], ["-", ""], ["\u09C3", "\u098B", "\u09E2", "\u09E0"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u09CC", "\u0994", "\u09D7"], ["\u09C8", "\u0990"], ["\u09BE", "\u0986"], ["\u09C0", "\u0988", "\u09E3", "\u09E1"], ["\u09C2", "\u098A"], ["\u09F1", "\u09AD"], ["\u09B9", "\u0999"], ["\u0997", "\u0998"], ["\u09A6", "\u09A7"], ["\u099C", "\u099D"], ["\u09A1", "\u09A2", "\u09DC", "\u09DD"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["\u09CB", "\u0993", "\u09F4", "\u09F5"], ["\u09C7", "\u098F", "\u09F6", "\u09F7"], ["\u09CD", "\u0985", "\u09F8", "\u09F9"], ["\u09BF", "\u0987", "\u09E2", "\u098C"], ["\u09C1", "\u0989"], ["\u09AA", "\u09AB"], ["\u09F0", "", "\u09F0", "\u09F1"], ["\u0995", "\u0996"], ["\u09A4", "\u09A5"], ["\u099A", "\u099B"], ["\u099F", "\u09A0"], ["\u09BC", "\u099E"]],
      [["Shift", "Shift"], ["\u09CE", "\u0983"], ["\u0982", "\u0981", "\u09FA"], ["\u09AE", "\u09A3"], ["\u09A8", "\u09F7"], ["\u09AC", "\""], ["\u09B2", "'"], ["\u09B8", "\u09B6"], [",", "\u09B7"], [".", ";"], ["\u09AF", "\u09DF"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["as"] };

  this.VKI_layout['\u0410\u0437\u04d9\u0440\u0431\u0430\u0458\u04b9\u0430\u043d\u04b9\u0430'] = {
    'name': "Azerbaijani Cyrillic", 'keys': [
      [["`", "~"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0458", "\u0408"], ["\u04AF", "\u04AE"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u04BB", "\u04BA"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u04B9", "\u04B8"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044B", "\u042B"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u049D", "\u049C"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["\u04D9", "\u04D8"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u0493", "\u0492"], ["\u0431", "\u0411"], ["\u04E9", "\u04E8"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["az-Cyrl"] };

  this.VKI_layout['Az\u0259rbaycanca'] = {
    'name': "Azerbaijani Latin", 'keys': [
      [["`", "~"], ["1", "!"], ["2", '"'], ["3", "\u2166"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["\u00FC", "\u00DC"], ["e", "E"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "\u0130"], ["o", "O"], ["p", "P"], ["\u00F6", "\u00D6"], ["\u011F", "\u011E"], ["\\", "/"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u0131", "I"], ["\u0259", "\u018F"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], ["\u00E7", "\u00C7"], ["\u015F", "\u015E"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["az"] };

  this.VKI_layout['\u0411\u0435\u043b\u0430\u0440\u0443\u0441\u043a\u0430\u044f'] = {
    'name': "Belarusian", 'keys': [
      [["\u0451", "\u0401"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043a", "\u041a"], ["\u0435", "\u0415"], ["\u043d", "\u041d"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u045e", "\u040e"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["'", "'"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044b", "\u042b"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043f", "\u041f"], ["\u0440", "\u0420"], ["\u043e", "\u041e"], ["\u043b", "\u041b"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u044d", "\u042d"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["/", "|"], ["\u044f", "\u042f"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043c", "\u041c"], ["\u0456", "\u0406"], ["\u0442", "\u0422"], ["\u044c", "\u042c"], ["\u0431", "\u0411"], ["\u044e", "\u042e"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["be"] };

  this.VKI_layout['Belgische / Belge'] = {
    'name': "Belgian", 'keys': [
      [["\u00b2", "\u00b3"], ["&", "1", "|"], ["\u00e9", "2", "@"], ['"', "3", "#"], ["'", "4"], ["(", "5"], ["\u00a7", "6", "^"], ["\u00e8", "7"], ["!", "8"], ["\u00e7", "9", "{"], ["\u00e0", "0", "}"], [")", "\u00b0"], ["-", "_"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["a", "A"], ["z", "Z"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["^", "\u00a8", "["], ["$", "*", "]"], ["\u03bc", "\u00a3", "`"]],
      [["Caps", "Caps"], ["q", "Q"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["m", "M"], ["\u00f9", "%", "\u00b4"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["w", "W"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], [",", "?"], [";", "."], [":", "/"], ["=", "+", "~"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["nl-BE", "fr-BE"] };

  this.VKI_layout['\u0411\u044a\u043b\u0433\u0430\u0440\u0441\u043a\u0438 \u0424\u043e\u043d\u0435\u0442\u0438\u0447\u0435\u043d'] = {
    'name': "Bulgarian Phonetic", 'keys': [
      [["\u0447", "\u0427"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u044F", "\u042F"], ["\u0432", "\u0412"], ["\u0435", "\u0415"], ["\u0440", "\u0420"], ["\u0442", "\u0422"], ["\u044A", "\u042A"], ["\u0443", "\u0423"], ["\u0438", "\u0418"], ["\u043E", "\u041E"], ["\u043F", "\u041F"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u044E", "\u042E"]],
      [["Caps", "Caps"], ["\u0430", "\u0410"], ["\u0441", "\u0421"], ["\u0434", "\u0414"], ["\u0444", "\u0424"], ["\u0433", "\u0413"], ["\u0445", "\u0425"], ["\u0439", "\u0419"], ["\u043A", "\u041A"], ["\u043B", "\u041B"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0437", "\u0417"], ["\u044C", "\u042C"], ["\u0446", "\u0426"], ["\u0436", "\u0416"], ["\u0431", "\u0411"], ["\u043D", "\u041D"], ["\u043C", "\u041C"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["bg"] };

  this.VKI_layout['\u0411\u044a\u043b\u0433\u0430\u0440\u0441\u043a\u0438'] = {
    'name': "Bulgarian BDS", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "?"], ["3", "+"], ["4", '"'], ["5", "%"], ["6", "="], ["7", ":"], ["8", "/"], ["9", "_"], ["0", "\u2116"], ["-", "\u0406"], ["=", "V"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], [",", "\u044b"], ["\u0443", "\u0423"], ["\u0435", "\u0415"], ["\u0438", "\u0418"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u043a", "\u041a"], ["\u0441", "\u0421"], ["\u0434", "\u0414"], ["\u0437", "\u0417"], ["\u0446", "\u0426"], [";", "\u00a7"], ["(", ")"]],
      [["Caps", "Caps"], ["\u044c", "\u042c"], ["\u044f", "\u042f"], ["\u0430", "\u0410"], ["\u043e", "\u041e"], ["\u0436", "\u0416"], ["\u0433", "\u0413"], ["\u0442", "\u0422"], ["\u043d", "\u041d"], ["\u0412", "\u0412"], ["\u043c", "\u041c"], ["\u0447", "\u0427"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u042e", "\u044e"], ["\u0439", "\u0419"], ["\u044a", "\u042a"], ["\u044d", "\u042d"], ["\u0444", "\u0424"], ["\u0445", "\u0425"], ["\u043f", "\u041f"], ["\u0440", "\u0420"], ["\u043b", "\u041b"], ["\u0431", "\u0411"], ["Shift", "Shift"]],
      [[" ", " "]]
    ]};

  this.VKI_layout['\u09ac\u09be\u0982\u09b2\u09be'] = {
    'name': "Bengali", 'keys': [
      [[""], ["1", "", "\u09E7"], ["2", "", "\u09E8"], ["3", "\u09CD\u09B0", "\u09E9"], ["4", "\u09B0\u09CD", "\u09EA"], ["5", "\u099C\u09CD\u09B0", "\u09EB"], ["6", "\u09A4\u09CD\u09B7", "\u09EC"], ["7", "\u0995\u09CD\u09B0", "\u09ED"], ["8", "\u09B6\u09CD\u09B0", "\u09EE"], ["9", "(", "\u09EF"], ["0", ")", "\u09E6"], ["-", "\u0983"], ["\u09C3", "\u098B", "\u09E2", "\u09E0"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u09CC", "\u0994", "\u09D7"], ["\u09C8", "\u0990"], ["\u09BE", "\u0986"], ["\u09C0", "\u0988", "\u09E3", "\u09E1"], ["\u09C2", "\u098A"], ["\u09AC", "\u09AD"], ["\u09B9", "\u0999"], ["\u0997", "\u0998"], ["\u09A6", "\u09A7"], ["\u099C", "\u099D"], ["\u09A1", "\u09A2", "\u09DC", "\u09DD"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["\u09CB", "\u0993", "\u09F4", "\u09F5"], ["\u09C7", "\u098F", "\u09F6", "\u09F7"], ["\u09CD", "\u0985", "\u09F8", "\u09F9"], ["\u09BF", "\u0987", "\u09E2", "\u098C"], ["\u09C1", "\u0989"], ["\u09AA", "\u09AB"], ["\u09B0", "", "\u09F0", "\u09F1"], ["\u0995", "\u0996"], ["\u09A4", "\u09A5"], ["\u099A", "\u099B"], ["\u099F", "\u09A0"], ["\u09BC", "\u099E"]],
      [["Shift", "Shift"], [""], ["\u0982", "\u0981", "\u09FA"], ["\u09AE", "\u09A3"], ["\u09A8"], ["\u09AC"], ["\u09B2"], ["\u09B8", "\u09B6"], [",", "\u09B7"], [".", "{"], ["\u09AF", "\u09DF"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["bn"] };

  this.VKI_layout['Bosanski'] = {
    'name': "Bosnian", 'keys': [
      [["\u00B8", "\u00A8"], ["1", "!", "~"], ["2", '"', "\u02C7"], ["3", "#", "^"], ["4", "$", "\u02D8"], ["5", "%", "\u00B0"], ["6", "&", "\u02DB"], ["7", "/", "`"], ["8", "(", "\u02D9"], ["9", ")", "\u00B4"], ["0", "=", "\u02DD"], ["'", "?", "\u00A8"], ["+", "*", "\u00B8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\\"], ["w", "W", "|"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u0161", "\u0160", "\u00F7"], ["\u0111", "\u0110", "\u00D7"], ["\u017E", "\u017D", "\u00A4"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F", "["], ["g", "G", "]"], ["h", "H"], ["j", "J"], ["k", "K", "\u0142"], ["l", "L", "\u0141"], ["\u010D", "\u010C"], ["\u0107", "\u0106", "\u00DF"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V", "@"], ["b", "B", "{"], ["n", "N", "}"], ["m", "M", "\u00A7"], [",", ";", "<"], [".", ":", ">"], ["-", "_", "\u00A9"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["bs"] };

  this.VKI_layout['Canadienne-fran\u00e7aise'] = {
    'name': "Canadian French", 'keys': [
      [["#", "|", "\\"], ["1", "!", "\u00B1"], ["2", '"', "@"], ["3", "/", "\u00A3"], ["4", "$", "\u00A2"], ["5", "%", "\u00A4"], ["6", "?", "\u00AC"], ["7", "&", "\u00A6"], ["8", "*", "\u00B2"], ["9", "(", "\u00B3"], ["0", ")", "\u00BC"], ["-", "_", "\u00BD"], ["=", "+", "\u00BE"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O", "\u00A7"], ["p", "P", "\u00B6"], ["^", "^", "["], ["\u00B8", "\u00A8", "]"], ["<", ">", "}"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":", "~"], ["`", "`", "{"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u00AB", "\u00BB", "\u00B0"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u00B5"], [",", "'", "\u00AF"], [".", ".", "\u00AD"], ["\u00E9", "\u00C9", "\u00B4"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fr-CA"] };

  this.VKI_layout['\u010cesky'] = {
    'name': "Czech", 'keys': [
      [[";", "\u00b0", "`", "~"], ["+", "1", "!"], ["\u011B", "2", "@"], ["\u0161", "3", "#"], ["\u010D", "4", "$"], ["\u0159", "5", "%"], ["\u017E", "6", "^"], ["\u00FD", "7", "&"], ["\u00E1", "8", "*"], ["\u00ED", "9", "("], ["\u00E9", "0", ")"], ["=", "%", "-", "_"], ["\u00B4", "\u02c7", "=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00FA", "/", "[", "{"], [")", "(", "]", "}"], ["\u00A8", "'", "\\", "|"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u016F", '"', ";", ":"], ["\u00A7", "!", "\u00a4", "^"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|", "", "\u02dd"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "?", "<", "\u00d7"], [".", ":", ">", "\u00f7"], ["-", "_", "/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["cs"] };

  this.VKI_layout['Dansk'] = {
    'name': "Danish", 'keys': [
      [["\u00bd", "\u00a7"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00a3"], ["4", "\u00a4", "$"], ["5", "%", "\u20ac"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["+", "?"], ["\u00b4", "`", "|"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00e5", "\u00c5"], ["\u00a8", "^", "~"], ["'", "*"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00e6", "\u00c6"], ["\u00f8", "\u00d8"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u03bc", "\u039c"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["da"] };

  this.VKI_layout['Deutsch'] = {
    'name': "German", 'keys': [
      [["^", "\u00b0"], ["1", "!"], ["2", '"', "\u00b2"], ["3", "\u00a7", "\u00b3"], ["4", "$"], ["5", "%"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["\u00df", "?", "\\"], ["\u00b4", "`"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "@"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00fc", "\u00dc"], ["+", "*", "~"], ["#", "'"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00f6", "\u00d6"], ["\u00e4", "\u00c4"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\u00a6"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u00b5"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["de"] };

  this.VKI_layout['Dingbats'] = {
    'name': "Dingbats", 'keys': [
      [["\u2764", "\u2765", "\u2766", "\u2767"], ["\u278a", "\u2780", "\u2776", "\u2768"], ["\u278b", "\u2781", "\u2777", "\u2769"], ["\u278c", "\u2782", "\u2778", "\u276a"], ["\u278d", "\u2783", "\u2779", "\u276b"], ["\u278e", "\u2784", "\u277a", "\u276c"], ["\u278f", "\u2785", "\u277b", "\u276d"], ["\u2790", "\u2786", "\u277c", "\u276e"], ["\u2791", "\u2787", "\u277d", "\u276f"], ["\u2792", "\u2788", "\u277e", "\u2770"], ["\u2793", "\u2789", "\u277f", "\u2771"], ["\u2795", "\u2796", "\u274c", "\u2797"], ["\u2702", "\u2704", "\u2701", "\u2703"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u2714", "\u2705", "\u2713"], ["\u2718", "\u2715", "\u2717", "\u2716"], ["\u271a", "\u2719", "\u271b", "\u271c"], ["\u271d", "\u271e", "\u271f", "\u2720"], ["\u2722", "\u2723", "\u2724", "\u2725"], ["\u2726", "\u2727", "\u2728", "\u2756"], ["\u2729", "\u272a", "\u272d", "\u2730"], ["\u272c", "\u272b", "\u272e", "\u272f"], ["\u2736", "\u2731", "\u2732", "\u2749"], ["\u273b", "\u273c", "\u273d", "\u273e"], ["\u2744", "\u2745", "\u2746", "\u2743"], ["\u2733", "\u2734", "\u2735", "\u2721"], ["\u2737", "\u2738", "\u2739", "\u273a"]],
      [["Caps", "Caps"], ["\u2799", "\u279a", "\u2798", "\u2758"], ["\u27b5", "\u27b6", "\u27b4", "\u2759"], ["\u27b8", "\u27b9", "\u27b7", "\u275a"], ["\u2794", "\u279c", "\u27ba", "\u27bb"], ["\u279d", "\u279e", "\u27a1", "\u2772"], ["\u27a9", "\u27aa", "\u27ab", "\u27ac"], ["\u27a4", "\u27a3", "\u27a2", "\u279b"], ["\u27b3", "\u27bc", "\u27bd", "\u2773"], ["\u27ad", "\u27ae", "\u27af", "\u27b1"], ["\u27a8", "\u27a6", "\u27a5", "\u27a7"], ["\u279f", "\u27a0", "\u27be", "\u27b2"], ["Enter", "Enter"]],
      [["Shift", "Shift"],  ["\u270c", "\u270b", "\u270a", "\u270d"], ["\u274f", "\u2750", "\u2751", "\u2752"], ["\u273f", "\u2740", "\u2741", "\u2742"], ["\u2747", "\u2748", "\u274a", "\u274b"], ["\u2757", "\u2755", "\u2762", "\u2763"], ["\u2753", "\u2754", "\u27b0", "\u27bf"], ["\u270f", "\u2710", "\u270e", "\u2774"], ["\u2712", "\u2711", "\u274d", "\u274e"], ["\u2709", "\u2706", "\u2708", "\u2707"], ["\u275b", "\u275d", "\u2761", "\u2775"], ["\u275c", "\u275e", "\u275f", "\u2760"], ["Shift", "Shift"]],
      [["AltLk", "AltLk"], [" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ]};

  this.VKI_layout['\u078b\u07a8\u0788\u07ac\u0780\u07a8\u0784\u07a6\u0790\u07b0'] = {
    'name': "Divehi", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", ")"], ["0", "("], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u07ab", "\u00d7"], ["\u07ae", "\u2019"], ["\u07a7", "\u201c"], ["\u07a9", "/"], ["\u07ad", ":"], ["\u078e", "\u07a4"], ["\u0783", "\u079c"], ["\u0789", "\u07a3"], ["\u078c", "\u07a0"], ["\u0780", "\u0799"], ["\u078d", "\u00f7"], ["[", "{"], ["]", "}"]],
      [["Caps", "Caps"], ["\u07a8", "<"], ["\u07aa", ">"], ["\u07b0", ".", ",", ","], ["\u07a6", "\u060c"], ["\u07ac", '"'], ["\u0788", "\u07a5"], ["\u0787", "\u07a2"], ["\u0782", "\u0798"], ["\u0786", "\u079a"], ["\u078a", "\u07a1"], ["\ufdf2", "\u061b", ";", ";"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["\u0792", "\u0796"], ["\u0791", "\u0795"], ["\u0790", "\u078f"], ["\u0794", "\u0797", "\u200D"], ["\u0785", "\u079f", "\u200C"], ["\u078b", "\u079b", "\u200E"], ["\u0784", "\u079D", "\u200F"], ["\u0781", "\\"], ["\u0793", "\u079e"], ["\u07af", "\u061f"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["dv"] };

  this.VKI_layout['Dvorak'] = {
    'name': "Dvorak", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["[", "{"], ["]", "}"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["'", '"'], [",", "<"], [".", ">"], ["p", "P"], ["y", "Y"], ["f", "F"], ["g", "G"], ["c", "C"], ["r", "R"], ["l", "L"], ["/", "?"], ["=", "+"], ["\\", "|"]],
      [["Caps", "Caps"], ["a", "A"], ["o", "O"], ["e", "E"], ["u", "U"], ["i", "I"], ["d", "D"], ["h", "H"], ["t", "T"], ["n", "N"], ["s", "S"], ["-", "_"], ["Enter", "Enter"]],
      [["Shift", "Shift"], [";", ":"], ["q", "Q"], ["j", "J"], ["k", "K"], ["x", "X"], ["b", "B"], ["m", "M"], ["w", "W"], ["v", "V"], ["z", "Z"], ["Shift", "Shift"]],
      [[" ", " "]]
    ]};

  this.VKI_layout['\u0395\u03bb\u03bb\u03b7\u03bd\u03b9\u03ba\u03ac'] = {
    'name': "Greek", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@", "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00a3"], ["5", "%", "\u00a7"], ["6", "^", "\u00b6"], ["7", "&"], ["8", "*", "\u00a4"], ["9", "(", "\u00a6"], ["0", ")", "\u00ba"], ["-", "_", "\u00b1"], ["=", "+", "\u00bd"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], [";", ":"], ["\u03c2", "^"], ["\u03b5", "\u0395"], ["\u03c1", "\u03a1"], ["\u03c4", "\u03a4"], ["\u03c5", "\u03a5"], ["\u03b8", "\u0398"], ["\u03b9", "\u0399"], ["\u03bf", "\u039f"], ["\u03c0", "\u03a0"], ["[", "{", "\u201c"], ["]", "}", "\u201d"], ["\\", "|", "\u00ac"]],
      [["Caps", "Caps"], ["\u03b1", "\u0391"], ["\u03c3", "\u03a3"], ["\u03b4", "\u0394"], ["\u03c6", "\u03a6"], ["\u03b3", "\u0393"], ["\u03b7", "\u0397"], ["\u03be", "\u039e"], ["\u03ba", "\u039a"], ["\u03bb", "\u039b"], ["\u0384", "\u00a8", "\u0385"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["\u03b6", "\u0396"], ["\u03c7", "\u03a7"], ["\u03c8", "\u03a8"], ["\u03c9", "\u03a9"], ["\u03b2", "\u0392"], ["\u03bd", "\u039d"], ["\u03bc", "\u039c"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["el"] };

  this.VKI_layout['Eesti'] = {
    'name': "Estonian", 'keys': [
      [["\u02C7", "~"], ["1", "!"], ["2", '"', "@", "@"], ["3", "#", "\u00A3", "\u00A3"], ["4", "\u00A4", "$", "$"], ["5", "%", "\u20AC"], ["6", "&"], ["7", "/", "{", "{"], ["8", "(", "[", "["], ["9", ")", "]", "]"], ["0", "=", "}", "}"], ["+", "?", "\\", "\\"], ["\u00B4", "`"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00FC", "\u00DC"], ["\u00F5", "\u00D5", "\u00A7", "\u00A7"], ["'", "*", "\u00BD", "\u00BD"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u0161", "\u0160"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00F6", "\u00D6"], ["\u00E4", "\u00C4", "^", "^"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|", "|"], ["z", "Z", "\u017E", "\u017D"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["et"] };

  this.VKI_layout['Espa\u00f1ol'] = {
    'name': "Spanish", 'keys': [
      [["\u00ba", "\u00aa", "\\"], ["1", "!", "|"], ["2", '"', "@"], ["3", "'", "#"], ["4", "$", "~"], ["5", "%", "\u20ac"], ["6", "&", "\u00ac"], ["7", "/"], ["8", "("], ["9", ")"], ["0", "="], ["'", "?"], ["\u00a1", "\u00bf"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["`", "^", "["], ["+", "*", "]"], ["\u00e7", "\u00c7", "}"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00f1", "\u00d1"], ["\u00b4", "\u00a8", "{"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["es"] };

  this.VKI_layout['\u062f\u0631\u06cc'] = {
    'name': "Dari", 'keys': [
      [["\u200D", "\u00F7", "~"], ["\u06F1", "!", "`"], ["\u06F2", "\u066C", "@"], ["\u06F3", "\u066B", "#"], ["\u06F4", "\u060B", "$"], ["\u06F5", "\u066A", "%"], ["\u06F6", "\u00D7", "^"], ["\u06F7", "\u060C", "&"], ["\u06F8", "*", "\u2022"], ["\u06F9", ")", "\u200E"], ["\u06F0", "(", "\u200F"], ["-", "\u0640", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0636", "\u0652", "\u00B0"], ["\u0635", "\u064C"], ["\u062B", "\u064D", "\u20AC"], ["\u0642", "\u064B", "\uFD3E"], ["\u0641", "\u064F", "\uFD3F"], ["\u063A", "\u0650", "\u0656"], ["\u0639", "\u064E", "\u0659"], ["\u0647", "\u0651", "\u0655"], ["\u062E", "]", "'"], ["\u062D", "[", '"'], ["\u062C", "}", "\u0681"], ["\u0686", "{", "\u0685"], ["\\", "|", "?"]],
      [["Caps", "Caps"], ["\u0634", "\u0624", "\u069A"], ["\u0633", "\u0626", "\u06CD"], ["\u06CC", "\u064A", "\u0649"], ["\u0628", "\u0625", "\u06D0"], ["\u0644", "\u0623", "\u06B7"], ["\u0627", "\u0622", "\u0671"], ["\u062A", "\u0629", "\u067C"], ["\u0646", "\u00BB", "\u06BC"], ["\u0645", "\u00AB", "\u06BA"], ["\u06A9", ":", ";"], ["\u06AF", "\u061B", "\u06AB"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0638", "\u0643", "\u06D2"], ["\u0637", "\u0653", "\u0691"], ["\u0632", "\u0698", "\u0696"], ["\u0631", "\u0670", "\u0693"], ["\u0630", "\u200C", "\u0688"], ["\u062F", "\u0654", "\u0689"], ["\u067E", "\u0621", "\u0679"], ["\u0648", ">", ","], [".", "<", "\u06C7"], ["/", "\u061F", "\u06C9"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fa-AF"] };

  this.VKI_layout['\u0641\u0627\u0631\u0633\u06cc'] = {
    'name': "Farsi", 'keys': [
      [["\u067e", "\u0651 "], ["1", "!", "\u00a1", "\u00b9"], ["2", "@", "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00a4", "\u00a3"], ["5", "%", "\u20ac"], ["6", "^", "\u00bc"], ["7", "&", "\u00bd"], ["8", "*", "\u00be"], ["9", "(", "\u2018"], ["0", ")", "\u2019"], ["-", "_", "\u00a5"], ["=", "+", "\u00d7", "\u00f7"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0636", "\u064e"], ["\u0635", "\u064b"], ["\u062b", "\u064f"], ["\u0642", "\u064c"], ["\u0641", "\u0644"], ["\u063a", "\u0625"], ["\u0639", "\u2018"], ["\u0647", "\u00f7"], ["\u062e", "\u00d7"], ["\u062d", "\u061b"], ["\u062c", "<"], ["\u0686", ">"], ["\u0698", "|"]],
      [["Caps", "Caps"], ["\u0634", "\u0650"], ["\u0633", "\u064d"], ["\u064a", "]"], ["\u0628", "["], ["\u0644", "\u0644"], ["\u0627", "\u0623"], ["\u062a", "\u0640"], ["\u0646", "\u060c"], ["\u0645", "\\"], ["\u06af", ":"], ["\u0643", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0638", "~"], ["\u0637", "\u0652"], ["\u0632", "}"], ["\u0631", "{"], ["\u0630", "\u0644"], ["\u062f", "\u0622"], ["\u0626", "\u0621"], ["\u0648", ","], [".", "."], ["/", "\u061f"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["fa"] };

  this.VKI_layout['F\u00f8royskt'] = {
    'name': "Faeroese", 'keys': [
      [["\u00BD", "\u00A7"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00A3"], ["4", "\u00A4", "$"], ["5", "%", "\u20AC"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["+", "?"], ["\u00B4", "`", "|"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00E5", "\u00C5", "\u00A8"], ["\u00F0", "\u00D0", "~"], ["'", "*"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00E6", "\u00C6"], ["\u00F8", "\u00D8", "^"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u00B5"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fo"] };

  this.VKI_layout['Fran\u00e7ais'] = {
    'name': "French", 'keys': [
      [["\u00b2", "\u00b3"], ["&", "1"], ["\u00e9", "2", "~"], ['"', "3", "#"], ["'", "4", "{"], ["(", "5", "["], ["-", "6", "|"], ["\u00e8", "7", "`"], ["_", "8", "\\"], ["\u00e7", "9", "^"], ["\u00e0", "0", "@"], [")", "\u00b0", "]"], ["=", "+", "}"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["a", "A"], ["z", "Z"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["^", "\u00a8"], ["$", "\u00a3", "\u00a4"], ["*", "\u03bc"]],
      [["Caps", "Caps"], ["q", "Q"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["m", "M"], ["\u00f9", "%"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["w", "W"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], [",", "?"], [";", "."], [":", "/"], ["!", "\u00a7"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fr"] };

  this.VKI_layout['Gaeilge'] = {
    'name': "Irish / Gaelic", 'keys': [
      [["`", "\u00AC", "\u00A6", "\u00A6"], ["1", "!"], ["2", '"'], ["3", "\u00A3"], ["4", "$", "\u20AC"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u00E9", "\u00C9"], ["r", "R"], ["t", "T"], ["y", "Y", "\u00FD", "\u00DD"], ["u", "U", "\u00FA", "\u00DA"], ["i", "I", "\u00ED", "\u00CD"], ["o", "O", "\u00F3", "\u00D3"], ["p", "P"], ["[", "{"], ["]", "}"], ["#", "~"]],
      [["Caps", "Caps"], ["a", "A", "\u00E1", "\u00C1"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":"], ["'", "@", "\u00B4", "`"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ga", "gd"] };

  this.VKI_layout['\u0a97\u0ac1\u0a9c\u0ab0\u0abe\u0aa4\u0ac0'] = {
    'name': "Gujarati", 'keys': [
      [[""], ["1", "\u0A8D", "\u0AE7"], ["2", "\u0AC5", "\u0AE8"], ["3", "\u0ACD\u0AB0", "\u0AE9"], ["4", "\u0AB0\u0ACD", "\u0AEA"], ["5", "\u0A9C\u0ACD\u0A9E", "\u0AEB"], ["6", "\u0AA4\u0ACD\u0AB0", "\u0AEC"], ["7", "\u0A95\u0ACD\u0AB7", "\u0AED"], ["8", "\u0AB6\u0ACD\u0AB0", "\u0AEE"], ["9", "(", "\u0AEF"], ["0", ")", "\u0AE6"], ["-", "\u0A83"], ["\u0AC3", "\u0A8B", "\u0AC4", "\u0AE0"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0ACC", "\u0A94"], ["\u0AC8", "\u0A90"], ["\u0ABE", "\u0A86"], ["\u0AC0", "\u0A88"], ["\u0AC2", "\u0A8A"], ["\u0AAC", "\u0AAD"], ["\u0AB9", "\u0A99"], ["\u0A97", "\u0A98"], ["\u0AA6", "\u0AA7"], ["\u0A9C", "\u0A9D"], ["\u0AA1", "\u0AA2"], ["\u0ABC", "\u0A9E"], ["\u0AC9", "\u0A91"]],
      [["Caps", "Caps"], ["\u0ACB", "\u0A93"], ["\u0AC7", "\u0A8F"], ["\u0ACD", "\u0A85"], ["\u0ABF", "\u0A87"], ["\u0AC1", "\u0A89"], ["\u0AAA", "\u0AAB"], ["\u0AB0"], ["\u0A95", "\u0A96"], ["\u0AA4", "\u0AA5"], ["\u0A9A", "\u0A9B"], ["\u0A9F", "\u0AA0"], ["Enter", "Enter"]],
      [["Shift", "Shift"], [""], ["\u0A82", "\u0A81", "", "\u0AD0"], ["\u0AAE", "\u0AA3"], ["\u0AA8"], ["\u0AB5"], ["\u0AB2", "\u0AB3"], ["\u0AB8", "\u0AB6"], [",", "\u0AB7"], [".", "\u0964", "\u0965", "\u0ABD"], ["\u0AAF"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["gu"] };

  this.VKI_layout['\u05e2\u05d1\u05e8\u05d9\u05ea'] = {
    'name': "Hebrew", 'keys': [
      [["~", "`"], ["1", "!"], ["2", "@"], ["3", "#"], ["4" , "$", "\u20aa"], ["5" , "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", ")"], ["0", "("], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["/", "Q"], ["'", "W"], ["\u05e7", "E", "\u20ac"], ["\u05e8", "R"], ["\u05d0", "T"], ["\u05d8", "Y"], ["\u05d5", "U", "\u05f0"], ["\u05df", "I"], ["\u05dd", "O"], ["\u05e4", "P"], ["\\", "|"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["\u05e9", "A"], ["\u05d3", "S"], ["\u05d2", "D"], ["\u05db", "F"], ["\u05e2", "G"], ["\u05d9", "H", "\u05f2"], ["\u05d7", "J", "\u05f1"], ["\u05dc", "K"], ["\u05da", "L"], ["\u05e3", ":"], ["," , '"'], ["]", "}"], ["[", "{"]],
      [["Shift", "Shift"], ["\u05d6", "Z"], ["\u05e1", "X"], ["\u05d1", "C"], ["\u05d4", "V"], ["\u05e0", "B"], ["\u05de", "N"], ["\u05e6", "M"], ["\u05ea", ">"], ["\u05e5", "<"], [".", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["he"] };

  this.VKI_layout['\u0926\u0947\u0935\u0928\u093e\u0917\u0930\u0940'] = {
    'name': "Devanagari", 'keys': [
      [["\u094A", "\u0912"], ["1", "\u090D", "\u0967"], ["2", "\u0945", "\u0968"], ["3", "\u094D\u0930", "\u0969"], ["4", "\u0930\u094D", "\u096A"], ["5", "\u091C\u094D\u091E", "\u096B"], ["6", "\u0924\u094D\u0930", "\u096C"], ["7", "\u0915\u094D\u0937", "\u096D"], ["8", "\u0936\u094D\u0930", "\u096E"], ["9", "(", "\u096F"], ["0", ")", "\u0966"], ["-", "\u0903"], ["\u0943", "\u090B", "\u0944", "\u0960"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u094C", "\u0914"], ["\u0948", "\u0910"], ["\u093E", "\u0906"], ["\u0940", "\u0908", "\u0963", "\u0961"], ["\u0942", "\u090A"], ["\u092C", "\u092D"], ["\u0939", "\u0919"], ["\u0917", "\u0918", "\u095A"], ["\u0926", "\u0927"], ["\u091C", "\u091D", "\u095B"], ["\u0921", "\u0922", "\u095C", "\u095D"], ["\u093C", "\u091E"], ["\u0949", "\u0911"]],
      [["Caps", "Caps"], ["\u094B", "\u0913"], ["\u0947", "\u090F"], ["\u094D", "\u0905"], ["\u093F", "\u0907", "\u0962", "\u090C"], ["\u0941", "\u0909"], ["\u092A", "\u092B", "", "\u095E"], ["\u0930", "\u0931"], ["\u0915", "\u0916", "\u0958", "\u0959"], ["\u0924", "\u0925"], ["\u091A", "\u091B", "\u0952"], ["\u091F", "\u0920", "", "\u0951"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0946", "\u090E", "\u0953"], ["\u0902", "\u0901", "", "\u0950"], ["\u092E", "\u0923", "\u0954"], ["\u0928", "\u0929"], ["\u0935", "\u0934"], ["\u0932", "\u0933"], ["\u0938", "\u0936"], [",", "\u0937", "\u0970"], [".", "\u0964", "\u0965", "\u093D"], ["\u092F", "\u095F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["hi-Deva"] };

  this.VKI_layout['\u0939\u093f\u0902\u0926\u0940'] = {
    'name': "Hindi", 'keys': [
      [["\u200d", "\u200c", "`", "~"], ["1", "\u090D", "\u0967", "!"], ["2", "\u0945", "\u0968", "@"], ["3", "\u094D\u0930", "\u0969", "#"], ["4", "\u0930\u094D", "\u096A", "$"], ["5", "\u091C\u094D\u091E", "\u096B", "%"], ["6", "\u0924\u094D\u0930", "\u096C", "^"], ["7", "\u0915\u094D\u0937", "\u096D", "&"], ["8", "\u0936\u094D\u0930", "\u096E", "*"], ["9", "(", "\u096F", "("], ["0", ")", "\u0966", ")"], ["-", "\u0903", "-", "_"], ["\u0943", "\u090B", "=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u094C", "\u0914"], ["\u0948", "\u0910"], ["\u093E", "\u0906"], ["\u0940", "\u0908"], ["\u0942", "\u090A"], ["\u092C", "\u092D"], ["\u0939", "\u0919"], ["\u0917", "\u0918"], ["\u0926", "\u0927"], ["\u091C", "\u091D"], ["\u0921", "\u0922", "[", "{"], ["\u093C", "\u091E", "]", "}"], ["\u0949", "\u0911", "\\", "|"]],
      [["Caps", "Caps"], ["\u094B", "\u0913"], ["\u0947", "\u090F"], ["\u094D", "\u0905"], ["\u093F", "\u0907"], ["\u0941", "\u0909"], ["\u092A", "\u092B"], ["\u0930", "\u0931"], ["\u0915", "\u0916"], ["\u0924", "\u0925"], ["\u091A", "\u091B", ";", ":"], ["\u091F", "\u0920", "'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], [""], ["\u0902", "\u0901", "", "\u0950"], ["\u092E", "\u0923"], ["\u0928"], ["\u0935"], ["\u0932", "\u0933"], ["\u0938", "\u0936"], [",", "\u0937", ",", "<"], [".", "\u0964", ".", ">"], ["\u092F", "\u095F", "/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["hi"] };

  this.VKI_layout['Hrvatski'] = {
    'name': "Croatian", 'keys': this.VKI_layout['Bosanski'].keys.slice(0), 'lang': ["hr"]
  };

  this.VKI_layout['\u0540\u0561\u0575\u0565\u0580\u0565\u0576 \u0561\u0580\u0565\u0582\u0574\u0578\u0582\u057f\u0584'] = {
    'name': "Western Armenian", 'keys': [
      [["\u055D", "\u055C"], [":", "1"], ["\u0571", "\u0541"], ["\u0575", "\u0545"], ["\u055B", "3"], [",", "4"], ["-", "9"], [".", "\u0587"], ["\u00AB", "("], ["\u00BB", ")"], ["\u0585", "\u0555"], ["\u057C", "\u054C"], ["\u056A", "\u053A"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u056D", "\u053D"], ["\u057E", "\u054E"], ["\u0567", "\u0537"], ["\u0580", "\u0550"], ["\u0564", "\u0534"], ["\u0565", "\u0535"], ["\u0568", "\u0538"], ["\u056B", "\u053B"], ["\u0578", "\u0548"], ["\u0562", "\u0532"], ["\u0579", "\u0549"], ["\u057B", "\u054B"], ["'", "\u055E"]],
      [["Caps", "Caps"], ["\u0561", "\u0531"], ["\u057D", "\u054D"], ["\u057F", "\u054F"], ["\u0586", "\u0556"], ["\u056F", "\u053F"], ["\u0570", "\u0540"], ["\u0573", "\u0543"], ["\u0584", "\u0554"], ["\u056C", "\u053C"], ["\u0569", "\u0539"], ["\u0583", "\u0553"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0566", "\u0536"], ["\u0581", "\u0551"], ["\u0563", "\u0533"], ["\u0582", "\u0552"], ["\u057A", "\u054A"], ["\u0576", "\u0546"], ["\u0574", "\u0544"], ["\u0577", "\u0547"], ["\u0572", "\u0542"], ["\u056E", "\u053E"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["hy-arevmda"] };

  this.VKI_layout['\u0540\u0561\u0575\u0565\u0580\u0565\u0576 \u0561\u0580\u0565\u0582\u0565\u056c\u0584'] = {
    'name': "Eastern Armenian", 'keys': [
      [["\u055D", "\u055C"], [":", "1"], ["\u0571", "\u0541"], ["\u0575", "\u0545"], ["\u055B", "3"], [",", "4"], ["-", "9"], [".", "\u0587"], ["\u00AB", "("], ["\u00BB", ")"], ["\u0585", "\u0555"], ["\u057C", "\u054C"], ["\u056A", "\u053A"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u056D", "\u053D"], ["\u0582", "\u0552"], ["\u0567", "\u0537"], ["\u0580", "\u0550"], ["\u057F", "\u054F"], ["\u0565", "\u0535"], ["\u0568", "\u0538"], ["\u056B", "\u053B"], ["\u0578", "\u0548"], ["\u057A", "\u054A"], ["\u0579", "\u0549"], ["\u057B", "\u054B"], ["'", "\u055E"]],
      [["Caps", "Caps"], ["\u0561", "\u0531"], ["\u057D", "\u054D"], ["\u0564", "\u0534"], ["\u0586", "\u0556"], ["\u0584", "\u0554"], ["\u0570", "\u0540"], ["\u0573", "\u0543"], ["\u056F", "\u053F"], ["\u056C", "\u053C"], ["\u0569", "\u0539"], ["\u0583", "\u0553"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0566", "\u0536"], ["\u0581", "\u0551"], ["\u0563", "\u0533"], ["\u057E", "\u054E"], ["\u0562", "\u0532"], ["\u0576", "\u0546"], ["\u0574", "\u0544"], ["\u0577", "\u0547"], ["\u0572", "\u0542"], ["\u056E", "\u053E"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["hy"] };

  this.VKI_layout['\u00cdslenska'] = {
    'name': "Icelandic", 'keys': [
      [["\u00B0", "\u00A8", "\u00B0"], ["1", "!"], ["2", '"'], ["3", "#"], ["4", "$"], ["5", "%", "\u20AC"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["\u00F6", "\u00D6", "\\"], ["-", "_"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "@"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00F0", "\u00D0"], ["'", "?", "~"], ["+", "*", "`"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00E6", "\u00C6"], ["\u00B4", "'", "^"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u00B5"], [",", ";"], [".", ":"], ["\u00FE", "\u00DE"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["is"] };

  this.VKI_layout['Italiano'] = {
    'name': "Italian", 'keys': [
      [["\\", "|"], ["1", "!"], ["2", '"'], ["3", "\u00a3"], ["4", "$", "\u20ac"], ["5", "%"], ["6", "&"], ["7", "/"], ["8", "("], ["9", ")"], ["0", "="], ["'", "?"], ["\u00ec", "^"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00e8", "\u00e9", "[", "{"], ["+", "*", "]", "}"], ["\u00f9", "\u00a7"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00f2", "\u00e7", "@"], ["\u00e0", "\u00b0", "#"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["it"] };

  this.VKI_layout['\u65e5\u672c\u8a9e'] = {
    'name': "Japanese Hiragana/Katakana", 'keys': [
      [["\uff5e"], ["\u306c", "\u30cc"], ["\u3075", '\u30d5'], ["\u3042", "\u30a2", "\u3041", "\u30a1"], ["\u3046", "\u30a6", "\u3045", "\u30a5"], ["\u3048", "\u30a8", "\u3047", "\u30a7"], ["\u304a", "\u30aa", "\u3049", "\u30a9"], ["\u3084", "\u30e4", "\u3083", "\u30e3"], ["\u3086", "\u30e6", "\u3085", "\u30e5"], ["\u3088", "\u30e8", "\u3087", "\u30e7"], ["\u308f", "\u30ef", "\u3092", "\u30f2"], ["\u307b", "\u30db", "\u30fc", "\uff1d"], ["\u3078", "\u30d8" , "\uff3e", "\uff5e"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u305f", "\u30bf"], ["\u3066", "\u30c6"], ["\u3044", "\u30a4", "\u3043", "\u30a3"], ["\u3059", "\u30b9"], ["\u304b", "\u30ab"], ["\u3093", "\u30f3"], ["\u306a", "\u30ca"], ["\u306b", "\u30cb"], ["\u3089", "\u30e9"], ["\u305b", "\u30bb"], ["\u3001", "\u3001", "\uff20", "\u2018"], ["\u3002", "\u3002", "\u300c", "\uff5b"], ["\uffe5", "", "", "\uff0a"], ['\u309B', '"', "\uffe5", "\uff5c"]],
      [["Caps", "Caps"], ["\u3061", "\u30c1"], ["\u3068", "\u30c8"], ["\u3057", "\u30b7"], ["\u306f", "\u30cf"], ["\u304d", "\u30ad"], ["\u304f", "\u30af"], ["\u307e", "\u30de"], ["\u306e", "\u30ce"], ["\u308c", "\u30ec", "\uff1b", "\uff0b"], ["\u3051", "\u30b1", "\uff1a", "\u30f6"], ["\u3080", "\u30e0", "\u300d", "\uff5d"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u3064", "\u30c4"], ["\u3055", "\u30b5"], ["\u305d", "\u30bd"], ["\u3072", "\u30d2"], ["\u3053", "\u30b3"], ["\u307f", "\u30df"], ["\u3082", "\u30e2"], ["\u306d", "\u30cd", "\u3001", "\uff1c"], ["\u308b", "\u30eb", "\u3002", "\uff1e"], ["\u3081", "\u30e1", "\u30fb", "\uff1f"], ["\u308d", "\u30ed", "", "\uff3f"], ["Shift", "Shift"]],
      [["AltLk", "AltLk"], [" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["ja"] };

  this.VKI_layout['\u10e5\u10d0\u10e0\u10d7\u10e3\u10da\u10d8'] = {
    'name': "Georgian", 'keys': [
      [["\u201E", "\u201C"], ["!", "1"], ["?", "2"], ["\u2116", "3"], ["\u00A7", "4"], ["%", "5"], [":", "6"], [".", "7"], [";", "8"], [",", "9"], ["/", "0"], ["\u2013", "-"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u10E6", "\u10E6"], ["\u10EF", "\u10EF"], ["\u10E3", "\u10E3"], ["\u10D9", "\u10D9"], ["\u10D4", "\u10D4", "\u10F1"], ["\u10DC", "\u10DC"], ["\u10D2", "\u10D2"], ["\u10E8", "\u10E8"], ["\u10EC", "\u10EC"], ["\u10D6", "\u10D6"], ["\u10EE", "\u10EE", "\u10F4"], ["\u10EA", "\u10EA"], ["(", ")"]],
      [["Caps", "Caps"], ["\u10E4", "\u10E4", "\u10F6"], ["\u10EB", "\u10EB"], ["\u10D5", "\u10D5", "\u10F3"], ["\u10D7", "\u10D7"], ["\u10D0", "\u10D0"], ["\u10DE", "\u10DE"], ["\u10E0", "\u10E0"], ["\u10DD", "\u10DD"], ["\u10DA", "\u10DA"], ["\u10D3", "\u10D3"], ["\u10DF", "\u10DF"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u10ED", "\u10ED"], ["\u10E9", "\u10E9"], ["\u10E7", "\u10E7"], ["\u10E1", "\u10E1"], ["\u10DB", "\u10DB"], ["\u10D8", "\u10D8", "\u10F2"], ["\u10E2", "\u10E2"], ["\u10E5", "\u10E5"], ["\u10D1", "\u10D1"], ["\u10F0", "\u10F0", "\u10F5"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ka"] };

  this.VKI_layout['\u049a\u0430\u0437\u0430\u049b\u0448\u0430'] = {
    'name': "Kazakh", 'keys': [
      [["(", ")"], ['"', "!"], ["\u04d9", "\u04d8"], ["\u0456", "\u0406"], ["\u04a3", "\u04a2"], ["\u0493", "\u0492"], [",", ";"], [".", ":"], ["\u04af", "\u04ae"], ["\u04b1", "\u04b0"], ["\u049b", "\u049a"], ["\u04e9", "\u04e8"], ["\u04bb", "\u04ba"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u044A", "\u042A"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044B", "\u042B"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u044D", "\u042D"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044C", "\u042C"], ["\u0431", "\u0411"], ["\u044E", "\u042E"], ["\u2116", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["kk"] };

  this.VKI_layout['\u1797\u17b6\u179f\u17b6\u1781\u17d2\u1798\u17c2\u179a'] = {
    'name': "Khmer", 'keys': [
      [["\u00AB", "\u00BB","\u200D"], ["\u17E1", "!","\u200C","\u17F1"], ["\u17E2", "\u17D7", "@", "\u17F2"], ["\u17E3", '"', "\u17D1", "\u17F3"], ["\u17E4", "\u17DB", "$", "\u17F4"], ["\u17E5", "%" ,"\u20AC", "\u17F5"], ["\u17E6", "\u17CD", "\u17D9", "\u17F6"], ["\u17E7", "\u17D0", "\u17DA", "\u17F7"], ["\u17E8", "\u17CF", "*", "\u17F8"], ["\u17E9", "(", "{", "\u17F9"], ["\u17E0", ")", "}", "\u17F0"], ["\u17A5", "\u17CC", "x"], ["\u17B2", "=", "\u17CE"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u1786", "\u1788", "\u17DC", "\u19E0"], ["\u17B9", "\u17BA", "\u17DD", "\u19E1"], ["\u17C1", "\u17C2", "\u17AF", "\u19E2"], ["\u179A", "\u17AC", "\u17AB", "\u19E3"], ["\u178F", "\u1791", "\u17A8", "\u19E4"], ["\u1799", "\u17BD", "\u1799\u17BE\u1784", "\u19E5"], ["\u17BB", "\u17BC", "", "\u19E6"], ["\u17B7", "\u17B8", "\u17A6", "\u19E7"], ["\u17C4", "\u17C5", "\u17B1", "\u19E8"], ["\u1795", "\u1797", "\u17B0", "\u19E9"], ["\u17C0", "\u17BF", "\u17A9", "\u19EA"], ["\u17AA", "\u17A7", "\u17B3", "\u19EB"], ["\u17AE", "\u17AD", "\\"]],
      [["Caps", "Caps"], ["\u17B6", "\u17B6\u17C6", "\u17B5", "\u19EC"], ["\u179F", "\u17C3", "", "\u19ED"], ["\u178A", "\u178C", "\u17D3", "\u19EE"], ["\u1790", "\u1792", "", "\u19EF"], ["\u1784", "\u17A2", "\u17A4", "\u19F0"], ["\u17A0", "\u17C7", "\u17A3", "\u19F1"], ["\u17D2", "\u1789", "\u17B4", "\u19F2"], ["\u1780", "\u1782", "\u179D", "\u19F3"], ["\u179B", "\u17A1", "\u17D8", "\u19F4"], ["\u17BE", "\u17C4\u17C7", "\u17D6", "\u19F5"], ["\u17CB", "\u17C9", "\u17C8", "\u19F6"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u178B", "\u178D", "|", "\u19F7"], ["\u1781", "\u1783", "\u1781\u17D2\u1789\u17BB\u17C6", "\u19F8"], ["\u1785", "\u1787", "-", "\u19F9"], ["\u179C", "\u17C1\u17C7", "+", "\u19FA"], ["\u1794", "\u1796", "\u179E", "\u19FB"], ["\u1793", "\u178E", "[", "\u19FC"], ["\u1798", "\u17C6", "]", "\u19FD"], ["\u17BB\u17C6", "\u17BB\u17C7", ",", "\u19FE"], ["\u17D4", "\u17D5", ".", "\u19FF"], ["\u17CA", "?", "/"], ["Shift", "Shift"]],
      [["\u200B", " ", "\u00A0", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["km"] };

  this.VKI_layout['\u0c95\u0ca8\u0ccd\u0ca8\u0ca1'] = {
    'name': "Kannada", 'keys': [
      [["\u0CCA", "\u0C92"], ["1", "", "\u0CE7"], ["2", "", "\u0CE8"], ["3", "\u0CCD\u0CB0", "\u0CE9"], ["4", "\u0CB0\u0CCD", "\u0CEA"], ["5", "\u0C9C\u0CCD\u0C9E", "\u0CEB"], ["6", "\u0CA4\u0CCD\u0CB0", "\u0CEC"], ["7", "\u0C95\u0CCD\u0CB7", "\u0CED"], ["8", "\u0CB6\u0CCD\u0CB0", "\u0CEE"], ["9", "(", "\u0CEF"], ["0", ")", "\u0CE6"], ["-", "\u0C83"], ["\u0CC3", "\u0C8B", "\u0CC4", "\u0CE0"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0CCC", "\u0C94"], ["\u0CC8", "\u0C90", "\u0CD6"], ["\u0CBE", "\u0C86"], ["\u0CC0", "\u0C88", "", "\u0CE1"], ["\u0CC2", "\u0C8A"], ["\u0CAC", "\u0CAD"], ["\u0CB9", "\u0C99"], ["\u0C97", "\u0C98"], ["\u0CA6", "\u0CA7"], ["\u0C9C", "\u0C9D"], ["\u0CA1", "\u0CA2"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["\u0CCB", "\u0C93"], ["\u0CC7", "\u0C8F", "\u0CD5"], ["\u0CCD", "\u0C85"], ["\u0CBF", "\u0C87", "", "\u0C8C"], ["\u0CC1", "\u0C89"], ["\u0CAA", "\u0CAB", "", "\u0CDE"], ["\u0CB0", "\u0CB1"], ["\u0C95", "\u0C96"], ["\u0CA4", "\u0CA5"], ["\u0C9A", "\u0C9B"], ["\u0C9F", "\u0CA0"], ["", "\u0C9E"]],
      [["Shift", "Shift"], ["\u0CC6", "\u0C8F"], ["\u0C82"], ["\u0CAE", "\u0CA3"], ["\u0CA8"], ["\u0CB5"], ["\u0CB2", "\u0CB3"], ["\u0CB8", "\u0CB6"], [",", "\u0CB7"], [".", "|"], ["\u0CAF"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["kn"] };

  this.VKI_layout['\ud55c\uad6d\uc5b4'] = {
    'name': "Korean", 'keys': [
      [["`", "~", "`", "~"], ["1", "!", "1", "!"], ["2", "@", "2", "@"], ["3", "#", "3", "#"], ["4", "$", "4", "$"], ["5", "%", "5", "%"], ["6", "^", "6", "^"], ["7", "&", "7", "&"], ["8", "*", "8", "*"], ["9", ")", "9", ")"], ["0", "(", "0", "("], ["-", "_", "-", "_"], ["=", "+", "=", "+"], ["\u20A9", "|", "\u20A9", "|"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u1107", "\u1108", "q", "Q"], ["\u110C", "\u110D", "w", "W"], ["\u1103", "\u1104", "e", "E"], ["\u1100", "\u1101", "r", "R"], ["\u1109", "\u110A", "t", "T"], ["\u116D", "", "y", "Y"], ["\u1167", "", "u", "U"], ["\u1163", "", "i", "I"], ["\u1162", "\u1164", "o", "O"], ["\u1166", "\u1168", "p", "P"], ["[", "{", "[", "{"], ["]", "}", "]", "}"]],
      [["Caps", "Caps"], ["\u1106", "", "a", "A"], ["\u1102", "", "s", "S"], ["\u110B", "", "d", "D"], ["\u1105", "", "f", "F"], ["\u1112", "", "g", "G"], ["\u1169", "", "h", "H"], ["\u1165", "", "j", "J"], ["\u1161", "", "k", "K"], ["\u1175", "", "l", "L"], [";", ":", ";", ":"], ["'", '"', "'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u110F", "", "z", "Z"], ["\u1110", "", "x", "X"], ["\u110E", "", "c", "C"], ["\u1111", "", "v", "V"], ["\u1172", "", "b", "B"], ["\u116E", "", "n", "N"], ["\u1173", "", "m", "M"], [",", "<", ",", "<"], [".", ">", ".", ">"], ["/", "?", "/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Kor", "Alt"]]
    ], 'lang': ["ko"] };

  this.VKI_layout['Kurd\u00ee'] = {
    'name': "Kurdish", 'keys': [
      [["\u20ac", "~"], ["\u0661", "!"], ["\u0662", "@"], ["\u0663", "#"], ["\u0664", "$"], ["\u0665", "%"], ["\u0666", "^"], ["\u0667", "&"], ["\u0668", "*"], ["\u0669", "("], ["\u0660", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0642", "`"], ["\u0648", "\u0648\u0648"], ["\u06d5", "\u064a"], ["\u0631", "\u0695"], ["\u062a", "\u0637"], ["\u06cc", "\u06ce"], ["\u0626", "\u0621"], ["\u062d", "\u0639"], ["\u06c6", "\u0624"], ["\u067e", "\u062b"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u0627", "\u0622"], ["\u0633", "\u0634"], ["\u062f", "\u0630"], ["\u0641", "\u0625"], ["\u06af", "\u063a"], ["\u0647", "\u200c"], ["\u0698", "\u0623"], ["\u06a9", "\u0643"], ["\u0644", "\u06b5"], ["\u061b", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0632", "\u0636"], ["\u062e", "\u0635"], ["\u062c", "\u0686"], ["\u06a4", "\u0638"], ["\u0628", "\u0649"], ["\u0646", "\u0629"], ["\u0645", "\u0640"], ["\u060c", "<"], [".", ">"], ["/", "\u061f"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["ku"] };

  this.VKI_layout['\u041a\u044b\u0440\u0433\u044b\u0437\u0447\u0430'] = {
    'name': "Kyrgyz", 'keys': [
      [["\u0451", "\u0401"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423", "\u04AF", "\u04AE"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D", "\u04A3", "\u04A2"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u044A", "\u042A"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044B", "\u042B"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E", "\u04E9", "\u04E8"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u044D", "\u042D"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044C", "\u042C"], ["\u0431", "\u0411"], ["\u044E", "\u042E"], [".", ","], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ky"] };

  this.VKI_layout['Latvie\u0161u'] = {
    'name': "Latvian", 'keys': [
      [["\u00AD", "?"], ["1", "!", "\u00AB"], ["2", "\u00AB", "", "@"], ["3", "\u00BB", "", "#"], ["4", "$", "\u20AC", "$"], ["5", "%", '"', "~"], ["6", "/", "\u2019", "^"], ["7", "&", "", "\u00B1"], ["8", "\u00D7", ":"], ["9", "("], ["0", ")"], ["-", "_", "\u2013", "\u2014"], ["f", "F", "=", ";"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u016B", "\u016A", "q", "Q"], ["g", "G", "\u0123", "\u0122"], ["j", "J"], ["r", "R", "\u0157", "\u0156"], ["m", "M", "w", "W"], ["v", "V", "y", "Y"], ["n", "N"], ["z", "Z"], ["\u0113", "\u0112"], ["\u010D", "\u010C"], ["\u017E", "\u017D", "[", "{"], ["h", "H", "]", "}"], ["\u0137", "\u0136"]],
      [["Caps", "Caps"], ["\u0161", "\u0160"], ["u", "U"], ["s", "S"], ["i", "I"], ["l", "L"], ["d", "D"], ["a", "A"], ["t", "T"], ["e", "E", "\u20AC"], ["c", "C"], ["\u00B4", "\u00B0", "\u00B4", "\u00A8"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0146", "\u0145"], ["b", "B", "x", "X"], ["\u012B", "\u012A"], ["k", "K", "\u0137", "\u0136"], ["p", "P"], ["o", "O", "\u00F5", "\u00D5"], ["\u0101", "\u0100"], [",", ";", "<"], [".", ":", ">"], ["\u013C", "\u013B"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["lv"] };

  this.VKI_layout['Lietuvi\u0173'] = {
    'name': "Lithuanian", 'keys': [
      [["`", "~"], ["\u0105", "\u0104"], ["\u010D", "\u010C"], ["\u0119", "\u0118"], ["\u0117", "\u0116"], ["\u012F", "\u012E"], ["\u0161", "\u0160"], ["\u0173", "\u0172"], ["\u016B", "\u016A"], ["\u201E", "("], ["\u201C", ")"], ["-", "_"], ["\u017E", "\u017D"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u2013", "\u20AC"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["lt"] };

  this.VKI_layout['Magyar'] = {
    'name': "Hungarian", 'keys': [
      [["0", "\u00a7"], ["1", "'", "~"], ["2", '"', "\u02c7"], ["3", "+", "\u02c6"], ["4", "!", "\u02d8"], ["5", "%", "\u00b0"], ["6", "/", "\u02db"], ["7", "=", "`"], ["8", "(", "\u02d9"], ["9", ")", "\u00b4"], ["\u00f6", "\u00d6", "\u02dd"], ["\u00fc", "\u00dc", "\u00a8"], ["\u00f3", "\u00d3", "\u00b8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\\"], ["w", "W", "|"], ["e", "E", "\u00c4"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U", "\u20ac"], ["i", "I", "\u00cd"], ["o", "O"], ["p", "P"], ["\u0151", "\u0150", "\u00f7"], ["\u00fa", "\u00da", "\u00d7"], ["\u0171", "\u0170", "\u00a4"]],
      [["Caps", "Caps"], ["a", "A", "\u00e4"], ["s", "S", "\u0111"], ["d", "D", "\u0110"], ["f", "F", "["], ["g", "G", "]"], ["h", "H"], ["j", "J", "\u00ed"], ["k", "K", "\u0141"], ["l", "L", "\u0142"], ["\u00e9", "\u00c9", "$"], ["\u00e1", "\u00c1", "\u00df"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u00ed", "\u00cd", "<"], ["y", "Y", ">"], ["x", "X", "#"], ["c", "C", "&"], ["v", "V", "@"], ["b", "B", "{"], ["n", "N", "}"], ["m", "M", "<"], [",", "?", ";"], [".", ":", ">"], ["-", "_", "*"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["hu"] };

  this.VKI_layout['Malti'] = {
    'name': "Maltese 48", 'keys': [
      [["\u010B", "\u010A", "`"], ["1", "!"], ["2", '"'], ["3", "\u20ac", "\u00A3"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u00E8", "\u00C8"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U", "\u00F9", "\u00D9"], ["i", "I", "\u00EC", "\u00cc"], ["o", "O", "\u00F2", "\u00D2"], ["p", "P"], ["\u0121", "\u0120", "[", "{"], ["\u0127", "\u0126", "]", "}"], ["#", "\u017e"]],
      [["Caps", "Caps"], ["a", "A", "\u00E0", "\u00C0"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":"], ["'", "@"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u017c", "\u017b", "\\", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?", "", "`"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["mt"] };

  this.VKI_layout['\u041c\u0430\u043a\u0435\u0434\u043e\u043d\u0441\u043a\u0438'] = {
    'name': "Macedonian Cyrillic", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "\u201E"], ["3", "\u201C"], ["4", "\u2019"], ["5", "%"], ["6", "\u2018"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0459", "\u0409"], ["\u045A", "\u040A"], ["\u0435", "\u0415", "\u20AC"], ["\u0440", "\u0420"], ["\u0442", "\u0422"], ["\u0455", "\u0405"], ["\u0443", "\u0423"], ["\u0438", "\u0418"], ["\u043E", "\u041E"], ["\u043F", "\u041F"], ["\u0448", "\u0428", "\u0402"], ["\u0453", "\u0403", "\u0452"], ["\u0436", "\u0416"]],
      [["Caps", "Caps"], ["\u0430", "\u0410"], ["\u0441", "\u0421"], ["\u0434", "\u0414"], ["\u0444", "\u0424", "["], ["\u0433", "\u0413", "]"], ["\u0445", "\u0425"], ["\u0458", "\u0408"], ["\u043A", "\u041A"], ["\u043B", "\u041B"], ["\u0447", "\u0427", "\u040B"], ["\u045C", "\u040C", "\u045B"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0451", "\u0401"], ["\u0437", "\u0417"], ["\u045F", "\u040F"], ["\u0446", "\u0426"], ["\u0432", "\u0412", "@"], ["\u0431", "\u0411", "{"], ["\u043D", "\u041D", "}"], ["\u043C", "\u041C", "\u00A7"], [",", ";"], [".", ":"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["mk"] };

  this.VKI_layout['\u0d2e\u0d32\u0d2f\u0d3e\u0d33\u0d02'] = {
    'name': "Malayalam", 'keys': [
      [["\u0D4A", "\u0D12"], ["1", "", "\u0D67"], ["2", "", "\u0D68"], ["3", "\u0D4D\u0D30", "\u0D69"], ["4", "", "\u0D6A"], ["5", "", "\u0D6B"], ["6", "", "\u0D6C"], ["7", "\u0D15\u0D4D\u0D37", "\u0D6D"], ["8", "", "\u0D6E"], ["9", "(", "\u0D6F"], ["0", ")", "\u0D66"], ["-", "\u0D03"], ["\u0D43", "\u0D0B", "", "\u0D60"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0D4C", "\u0D14", "\u0D57"], ["\u0D48", "\u0D10"], ["\u0D3E", "\u0D06"], ["\u0D40", "\u0D08", "", "\u0D61"], ["\u0D42", "\u0D0A"], ["\u0D2C", "\u0D2D"], ["\u0D39", "\u0D19"], ["\u0D17", "\u0D18"], ["\u0D26", "\u0D27"], ["\u0D1C", "\u0D1D"], ["\u0D21", "\u0D22"], ["", "\u0D1E"]],
      [["Caps", "Caps"], ["\u0D4B", "\u0D13"], ["\u0D47", "\u0D0F"], ["\u0D4D", "\u0D05", "", "\u0D0C"], ["\u0D3F", "\u0D07"], ["\u0D41", "\u0D09"], ["\u0D2A", "\u0D2B"], ["\u0D30", "\u0D31"], ["\u0D15", "\u0D16"], ["\u0D24", "\u0D25"], ["\u0D1A", "\u0D1B"], ["\u0D1F", "\u0D20"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0D46", "\u0D0F"], ["\u0D02"], ["\u0D2E", "\u0D23"], ["\u0D28"], ["\u0D35", "\u0D34"], ["\u0D32", "\u0D33"], ["\u0D38", "\u0D36"], [",", "\u0D37"], ["."], ["\u0D2F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ml"] };

  this.VKI_layout['Misc. Symbols'] = {
    'name': "Misc. Symbols", 'keys': [
      [["\u2605", "\u2606", "\u260e", "\u260f"], ["\u2648", "\u2673", "\u2659", "\u2630"], ["\u2649", "\u2674", "\u2658", "\u2631"], ["\u264a", "\u2675", "\u2657", "\u2632"], ["\u264b", "\u2676", "\u2656", "\u2633"], ["\u264c", "\u2677", "\u2655", "\u2634"], ["\u264d", "\u2678", "\u2654", "\u2635"], ["\u264e", "\u2679", "\u265f", "\u2636"], ["\u264f", "\u267a", "\u265e", "\u2637"], ["\u2650", "\u267b", "\u265d", "\u2686"], ["\u2651", "\u267c", "\u265c", "\u2687"], ["\u2652", "\u267d", "\u265b", "\u2688"], ["\u2653", "\u2672", "\u265a", "\u2689"], ["Bksp", "Bksp"]],
      [["\u263f", "\u2680", "\u268a", "\u26a2"], ["\u2640", "\u2681", "\u268b", "\u26a3"], ["\u2641", "\u2682", "\u268c", "\u26a4"], ["\u2642", "\u2683", "\u268d", "\u26a5"], ["\u2643", "\u2684", "\u268e", "\u26a6"], ["\u2644", "\u2685", "\u268f", "\u26a7"], ["\u2645", "\u2620", "\u26ff", "\u26a8"], ["\u2646", "\u2622", "\u2692", "\u26a9"], ["\u2647", "\u2623", "\u2693", "\u26b2"], ["\u2669", "\u266d", "\u2694", "\u26ac"], ["\u266a", "\u266e", "\u2695", "\u26ad"], ["\u266b", "\u266f", "\u2696", "\u26ae"], ["\u266c", "\u2607", "\u2697", "\u26af"], ["\u26f9", "\u2608", "\u2698", "\u26b0"], ["\u267f", "\u262e", "\u2638", "\u2609"]],
      [["Tab", "Tab"], ["\u261e", "\u261c", "\u261d", "\u261f"], ["\u261b", "\u261a", "\u2618", "\u2619"], ["\u2602", "\u2614", "\u26f1", "\u26d9"], ["\u2615", "\u2668", "\u26fe", "\u26d8"], ["\u263a", "\u2639", "\u263b", "\u26dc"], ["\u2617", "\u2616", "\u26ca", "\u26c9"], ["\u2660", "\u2663", "\u2665", "\u2666"], ["\u2664", "\u2667", "\u2661", "\u2662"], ["\u26c2", "\u26c0", "\u26c3", "\u26c1"], ["\u2624", "\u2625", "\u269a", "\u26b1"], ["\u2610", "\u2611", "\u2612", "\u2613"], ["\u2628", "\u2626", "\u2627", "\u2629"], ["\u262a", "\u262b", "\u262c", "\u262d"], ["\u26fa", "\u26fb", "\u26fc", "\u26fd"]],
      [["Caps", "Caps"], ["\u262f", "\u2670", "\u2671", "\u267e"], ["\u263c", "\u2699", "\u263d", "\u263e"], ["\u26c4", "\u2603", "\u26c7", "\u26c6"], ["\u26a0", "\u26a1", "\u2621", "\u26d4"], ["\u26e4", "\u26e5", "\u26e6", "\u26e7"], ["\u260a", "\u260b", "\u260c", "\u260d"], ["\u269c", "\u269b", "\u269d", "\u2604"], ["\u26b3", "\u26b4", "\u26b5", "\u26b6"], ["\u26b7", "\u26bf", "\u26b8", "\u26f8"], ["\u26b9", "\u26ba", "\u26bb", "\u26bc"], ["\u26bd", "\u26be", "\u269f", "\u269e"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u2600", "\u2601", "\u26c5", "\u26c8"], ["\u2691", "\u2690", "\u26ab", "\u26aa"], ["\u26cb", "\u26cc", "\u26cd", "\u26ce"], ["\u26cf", "\u26d0", "\u26d1", "\u26d2"], ["\u26d3", "\u26d5", "\u26d6", "\u26d7"], ["\u26da", "\u26db", "\u26dd", "\u26de"], ["\u26df", "\u26e0", "\u26e1", "\u26e2"], ["\u26e3", "\u26e8", "\u26e9", "\u26ea"], ["\u26eb", "\u26ec", "\u26ed", "\u26ee"], ["\u26ef", "\u26f0", "\u26f2", "\u26f3"], ["\u26f4", "\u26f5", "\u26f6", "\u26f7"], ["Shift", "Shift"]],
      [["AltLk", "AltLk"], [" ", " ", " ", " "], ["Alt", "Alt"]]
    ]};

  this.VKI_layout['\u041c\u043e\u043d\u0433\u043e\u043b'] = {
    'name': "Mongolian Cyrillic", 'keys': [
      [["=", "+"], ["\u2116", "1"], ["-", "2"], ['"', "3"], ["\u20AE", "4"], [":", "5"], [".", "6"], ["_", "7"], [",", "8"], ["%", "9"], ["?", "0"], ["\u0435", "\u0415"], ["\u0449", "\u0429"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0444", "\u0424"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u0436", "\u0416"], ["\u044d", "\u042d"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u04af", "\u04AE"], ["\u0437", "\u0417"], ["\u043A", "\u041a"], ["\u044A", "\u042A"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u0439", "\u0419"], ["\u044B", "\u042B"], ["\u0431", "\u0411"], ["\u04e9", "\u04e8"], ["\u0430", "\u0410"], ["\u0445", "\u0425"], ["\u0440", "\u0420"], ["\u043e", "\u041e"], ["\u043B", "\u041b"], ["\u0434", "\u0414"], ["\u043f", "\u041f"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0451", "\u0401"], ["\u0441", "\u0421"], ["\u043c", "\u041c"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044c", "\u042c"], ["\u0432", "\u0412"], ["\u044e", "\u042e"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["mn"] };

  this.VKI_layout['\u092e\u0930\u093e\u0920\u0940'] = {
    'name': "Marathi", 'keys': [
      [["", "", "`", "~"], ["\u0967", "\u090D", "1", "!"], ["\u0968", "\u0945", "2", "@"], ["\u0969", "\u094D\u0930", "3", "#"], ["\u096A", "\u0930\u094D", "4", "$"], ["\u096B", "\u091C\u094D\u091E", "5", "%"], ["\u096C", "\u0924\u094D\u0930", "6", "^"], ["\u096D", "\u0915\u094D\u0937", "7", "&"], ["\u096E", "\u0936\u094D\u0930", "8", "*"], ["\u096F", "(", "9", "("], ["\u0966", ")", "0", ")"], ["-", "\u0903", "-", "_"], ["\u0943", "\u090B", "=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u094C", "\u0914"], ["\u0948", "\u0910"], ["\u093E", "\u0906"], ["\u0940", "\u0908"], ["\u0942", "\u090A"], ["\u092C", "\u092D"], ["\u0939", "\u0919"], ["\u0917", "\u0918"], ["\u0926", "\u0927"], ["\u091C", "\u091D"], ["\u0921", "\u0922", "[", "{"], ["\u093C", "\u091E", "]", "}"], ["\u0949", "\u0911", "\\", "|"]],
      [["Caps", "Caps"], ["\u094B", "\u0913"], ["\u0947", "\u090F"], ["\u094D", "\u0905"], ["\u093F", "\u0907"], ["\u0941", "\u0909"], ["\u092A", "\u092B"], ["\u0930", "\u0931"], ["\u0915", "\u0916"], ["\u0924", "\u0925"], ["\u091A", "\u091B", ";", ":"], ["\u091F", "\u0920", "'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], [""], ["\u0902", "\u0901", "", "\u0950"], ["\u092E", "\u0923"], ["\u0928"], ["\u0935"], ["\u0932", "\u0933"], ["\u0938", "\u0936"], [",", "\u0937", ",", "<"], [".", "\u0964", ".", ">"], ["\u092F", "\u095F", "/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["mr"] };

  this.VKI_layout['\u1019\u103c\u1014\u103a\u1019\u102c\u1018\u102c\u101e\u102c'] = {
    'name': "Burmese", 'keys': [
      [["\u1039`", "~"], ["\u1041", "\u100D"], ["\u1042", "\u100E"], ["\u1043", "\u100B"], ["\u1044", "\u1000\u103B\u1015\u103A"], ["\u1045", "%"], ["\u1046", "/"], ["\u1047", "\u101B"], ["\u1048", "\u1002"], ["\u1049", "("], ["\u1040", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u1006", "\u1029"], ["\u1010", "\u1040"], ["\u1014", "\u103F"], ["\u1019", "\u1023"], ["\u1021", "\u1024"], ["\u1015", "\u104C"], ["\u1000", "\u1009"], ["\u1004", "\u104D"], ["\u101E", "\u1025"], ["\u1005", "\u100F"], ["\u101F", "\u1027"], ["\u2018", "\u2019"], ["\u104F", "\u100B\u1039\u100C"]],
      [["Caps", "Caps"], ["\u200B\u1031", "\u1017"], ["\u200B\u103B", "\u200B\u103E"], ["\u200B\u102D", "\u200B\u102E"], ["\u200B\u103A", "\u1004\u103A\u1039\u200B"], ["\u200B\u102B", "\u200B\u103D"], ["\u200B\u1037", "\u200B\u1036"], ["\u200B\u103C", "\u200B\u1032"], ["\u200B\u102F", "\u200B\u102F"], ["\u200B\u1030", "\u200B\u1030"], ["\u200B\u1038", "\u200B\u102B\u103A"], ["\u1012", "\u1013"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u1016", "\u1007"], ["\u1011", "\u100C"], ["\u1001", "\u1003"], ["\u101C", "\u1020"], ["\u1018", "\u1026"], ["\u100A", "\u1008"], ["\u200B\u102C", "\u102A"], ["\u101A", "\u101B"], [".", "\u101B"], ["\u104B", "\u104A"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["my"] };

  this.VKI_layout['Nederlands'] = {
    'name': "Dutch", 'keys': [
      [["@", "\u00a7", "\u00ac"], ["1", "!", "\u00b9"], ["2", '"', "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00bc"], ["5", "%", "\u00bd"], ["6", "&", "\u00be"], ["7", "_", "\u00a3"], ["8", "(", "{"], ["9", ")", "}"], ["0", "'"], ["/", "?", "\\"], ["\u00b0", "~", "\u00b8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R", "\u00b6"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00a8", "^"], ["*", "|"], ["<", ">"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u00df"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["+", "\u00b1"], ["\u00b4", "`"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["]", "[", "\u00a6"], ["z", "Z", "\u00ab"], ["x", "X", "\u00bb"], ["c", "C", "\u00a2"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u00b5"], [",", ";"], [".", ":", "\u00b7"], ["-", "="], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["nl"] };

  this.VKI_layout['Norsk'] = {
    'name': "Norwegian", 'keys': [
      [["|", "\u00a7"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00a3"], ["4", "\u00a4", "$"], ["5", "%"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["+", "?"], ["\\", "`", "\u00b4"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00e5", "\u00c5"], ["\u00a8", "^", "~"], ["'", "*"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00f8", "\u00d8"], ["\u00e6", "\u00c6"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u03bc", "\u039c"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["no", "nb", "nn"] };

  this.VKI_layout['\u067e\u069a\u062a\u0648'] = {
    'name': "Pashto", 'keys': [
      [["\u200d", "\u00f7", "`"], ["\u06f1", "!", "`"], ["\u06f2", "\u066c", "@"], ["\u06f3", "\u066b", "\u066b"], ["\u06f4", "\u00a4", "\u00a3"], ["\u06f5", "\u066a", "%"], ["\u06f6", "\u00d7", "^"], ["\u06f7", "\u00ab", "&"], ["\u06f8", "\u00bb", "*"], ["\u06f9", "(", "\ufdf2"], ["\u06f0", ")", "\ufefb"], ["-", "\u0640", "_"], ["=", "+", "\ufe87", "\u00f7"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0636", "\u0652", "\u06d5"], ["\u0635", "\u064c", "\u0653"], ["\u062b", "\u064d", "\u20ac"], ["\u0642", "\u064b", "\ufef7"], ["\u0641", "\u064f", "\ufef5"], ["\u063a", "\u0650", "'"], ["\u0639", "\u064e", "\ufe84"], ["\u0647", "\u0651", "\u0670"], ["\u062e", "\u0681", "'"], ["\u062d", "\u0685", '"'], ["\u062c", "]", "}"], ["\u0686", "[", "{"], ["\\", "\u066d", "|"]],
      [["Caps", "Caps"], ["\u0634", "\u069a", "\ufbb0"], ["\u0633", "\u06cd", "\u06d2"], ["\u06cc", "\u064a", "\u06d2"], ["\u0628", "\u067e", "\u06ba"], ["\u0644", "\u0623", "\u06b7"], ["\u0627", "\u0622", "\u0671"], ["\u062a", "\u067c", "\u0679"], ["\u0646", "\u06bc", "<"], ["\u0645", "\u0629", ">"], ["\u06a9", ":", "\u0643"], ["\u06af", "\u061b", "\u06ab"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0638", "\u0626", "?"], ["\u0637", "\u06d0", ";"], ["\u0632", "\u0698", "\u0655"], ["\u0631", "\u0621", "\u0654"], ["\u0630", "\u200c", "\u0625"], ["\u062f", "\u0689", "\u0688"], ["\u0693", "\u0624", "\u0691"], ["\u0648", "\u060c", ","], ["\u0696", ".", "\u06c7"], ["/", "\u061f", "\u06c9"], ["Shift", "Shift", "\u064d"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["ps"] };

  this.VKI_layout['\u0a2a\u0a70\u0a1c\u0a3e\u0a2c\u0a40'] = {
    'name': "Punjabi (Gurmukhi)", 'keys': [
      [[""], ["1", "\u0A4D\u0A35", "\u0A67", "\u0A67"], ["2", "\u0A4D\u0A2F", "\u0A68", "\u0A68"], ["3", "\u0A4D\u0A30", "\u0A69", "\u0A69"], ["4", "\u0A71", "\u0A6A", "\u0A6A"], ["5", "", "\u0A6B", "\u0A6B"], ["6", "", "\u0A6C", "\u0A6C"], ["7", "", "\u0A6D", "\u0A6D"], ["8", "", "\u0A6E", "\u0A6E"], ["9", "(", "\u0A6F", "\u0A6F"], ["0", ")", "\u0A66", "\u0A66"], ["-"], [""], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0A4C", "\u0A14"], ["\u0A48", "\u0A10"], ["\u0A3E", "\u0A06"], ["\u0A40", "\u0A08"], ["\u0A42", "\u0A0A"], ["\u0A2C", "\u0A2D"], ["\u0A39", "\u0A19"], ["\u0A17", "\u0A18", "\u0A5A", "\u0A5A"], ["\u0A26", "\u0A27"], ["\u0A1C", "\u0A1D", "\u0A5B", "\u0A5B"], ["\u0A21", "\u0A22", "\u0A5C", "\u0A5C"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["\u0A4B", "\u0A13"], ["\u0A47", "\u0A0F"], ["\u0A4D", "\u0A05"], ["\u0A3F", "\u0A07"], ["\u0A41", "\u0A09"], ["\u0A2A", "\u0A2B", "\u0A5E", "\u0A5E"], ["\u0A30"], ["\u0A15", "\u0A16", "\u0A59", "\u0A59"], ["\u0A24", "\u0A25"], ["\u0A1A", "\u0A1B"], ["\u0A1F", "\u0A20"], ["\u0A3C", "\u0A1E"]],
      [["Shift", "Shift"], [""], ["\u0A02", "\u0A02"], ["\u0A2E", "\u0A23"], ["\u0A28"], ["\u0A35", "\u0A72", "\u0A73", "\u0A73"], ["\u0A32", "\u0A33"], ["\u0A38", "\u0A36"], [","], [".", "|", "\u0965", "\u0965"], ["\u0A2F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["pa"] };

  this.VKI_layout['\u62fc\u97f3 (Pinyin)'] = {
    'name': "Pinyin", 'keys': [
      [["`", "~", "\u4e93", "\u301C"], ["1", "!", "\uFF62"], ["2", "@", "\uFF63"], ["3", "#", "\u301D"], ["4", "$", "\u301E"], ["5", "%", "\u301F"], ["6", "^", "\u3008"], ["7", "&", "\u3009"], ["8", "*", "\u302F"], ["9", "(", "\u300A"], ["0", ")", "\u300B"], ["-", "_", "\u300E"], ["=", "+", "\u300F"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\u0101", "\u0100"], ["w", "W", "\u00E1", "\u00C1"], ["e", "E", "\u01CE", "\u01CD"], ["r", "R", "\u00E0", "\u00C0"], ["t", "T", "\u0113", "\u0112"], ["y", "Y", "\u00E9", "\u00C9"], ["u", "U", "\u011B", "\u011A"], ["i", "I", "\u00E8", "\u00C8"], ["o", "O", "\u012B", "\u012A"], ["p", "P", "\u00ED", "\u00CD"], ["[", "{", "\u01D0", "\u01CF"], ["]", "}", "\u00EC", "\u00CC"], ["\\", "|", "\u3020"]],
      [["Caps", "Caps"], ["a", "A", "\u014D", "\u014C"], ["s", "S", "\u00F3", "\u00D3"], ["d", "D", "\u01D2", "\u01D1"], ["f", "F", "\u00F2", "\u00D2"], ["g", "G", "\u00fc", "\u00dc"], ["h", "H", "\u016B", "\u016A"], ["j", "J", "\u00FA", "\u00DA"], ["k", "K", "\u01D4", "\u01D3"], ["l", "L", "\u00F9", "\u00D9"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z", "\u01D6", "\u01D5"], ["x", "X", "\u01D8", "\u01D7"], ["c", "C", "\u01DA", "\u01D9"], ["v", "V", "\u01DC", "\u01DB"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<", "\u3001"], [".", ">", "\u3002"], ["/", "?"], ["Shift", "Shift"]],
      [["AltLk", "AltLk"], [" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["zh-Latn"] };

  this.VKI_layout['Polski'] = {
    'name': "Polish (214)", 'keys': [
      [["\u02DB", "\u00B7"], ["1", "!", "~"], ["2", '"', "\u02C7"], ["3", "#", "^"], ["4", "\u00A4", "\u02D8"], ["5", "%", "\u00B0"], ["6", "&", "\u02DB"], ["7", "/", "`"], ["8", "(", "\u00B7"], ["9", ")", "\u00B4"], ["0", "=", "\u02DD"], ["+", "?", "\u00A8"], ["'", "*", "\u00B8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\\"], ["w", "W", "\u00A6"], ["e", "E"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U", "\u20AC"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u017C", "\u0144", "\u00F7"], ["\u015B", "\u0107", "\u00D7"], ["\u00F3", "\u017A"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u0111"], ["d", "D", "\u0110"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u0142", "\u0141", "$"], ["\u0105", "\u0119", "\u00DF"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V", "@"], ["b", "B", "{"], ["n", "N", "}"], ["m", "M", "\u00A7"], [",", ";", "<"], [".", ":", ">"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ]};

  this.VKI_layout['Polski Programisty'] = {
    'name': "Polish Programmers", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u0119", "\u0118"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O", "\u00f3", "\u00d3"], ["p", "P"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["a", "A", "\u0105", "\u0104"], ["s", "S", "\u015b", "\u015a"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L", "\u0142", "\u0141"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z", "\u017c", "\u017b"], ["x", "X", "\u017a", "\u0179"], ["c", "C", "\u0107", "\u0106"], ["v", "V"], ["b", "B"], ["n", "N", "\u0144", "\u0143"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["pl"] };

  this.VKI_layout['Portugu\u00eas Brasileiro'] = {
    'name': "Portuguese (Brazil)", 'keys': [
      [["'", '"'], ["1", "!", "\u00b9"], ["2", "@", "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00a3"], ["5", "%", "\u00a2"], ["6", "\u00a8", "\u00ac"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+", "\u00a7"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "/"], ["w", "W", "?"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00b4", "`"], ["[", "{", "\u00aa"], ["Enter", "Enter"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00e7", "\u00c7"], ["~", "^"], ["]", "}", "\u00ba"], ["/", "?"]],
      [["Shift", "Shift"], ["\\", "|"], ["z", "Z"], ["x", "X"], ["c", "C", "\u20a2"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], [":", ":"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["pt-BR"] };

  this.VKI_layout['Portugu\u00eas'] = {
    'name': "Portuguese", 'keys': [
      [["\\", "|"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00a3"], ["4", "$", "\u00a7"], ["5", "%"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["'", "?"], ["\u00ab", "\u00bb"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["+", "*", "\u00a8"], ["\u00b4", "`"], ["~", "^"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00e7", "\u00c7"], ["\u00ba", "\u00aa"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["pt"] };

  this.VKI_layout['Rom\u00e2n\u0103'] = {
    'name': "Romanian", 'keys': [
      [["\u201E", "\u201D", "`", "~"], ["1", "!", "~"], ["2", "@", "\u02C7"], ["3", "#", "^"], ["4", "$", "\u02D8"], ["5", "%", "\u00B0"], ["6", "^", "\u02DB"], ["7", "&", "`"], ["8", "*", "\u02D9"], ["9", "(", "\u00B4"], ["0", ")", "\u02DD"], ["-", "_", "\u00A8"], ["=", "+", "\u00B8", "\u00B1"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P", "\u00A7"], ["\u0103", "\u0102", "[", "{"], ["\u00EE", "\u00CE", "]", "}"], ["\u00E2", "\u00C2", "\\", "|"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u00df"], ["d", "D", "\u00f0", "\u00D0"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L", "\u0142", "\u0141"], [(this.VKI_isIElt8) ? "\u015F" : "\u0219", (this.VKI_isIElt8) ? "\u015E" : "\u0218", ";", ":"], [(this.VKI_isIElt8) ? "\u0163" : "\u021B", (this.VKI_isIElt8) ? "\u0162" : "\u021A", "\'", "\""], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["z", "Z"], ["x", "X"], ["c", "C", "\u00A9"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";", "<", "\u00AB"], [".", ":", ">", "\u00BB"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ro"] };

  this.VKI_layout['\u0420\u0443\u0441\u0441\u043a\u0438\u0439'] = {
    'name': "Russian", 'keys': [
      [["\u0451", "\u0401"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u044A", "\u042A"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044B", "\u042B"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u044D", "\u042D"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["/", "|"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044C", "\u042C"], ["\u0431", "\u0411"], ["\u044E", "\u042E"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["ru"] };

  this.VKI_layout['Schweizerdeutsch'] = {
    'name': "Swiss German", 'keys': [
      [["\u00A7", "\u00B0"], ["1", "+", "\u00A6"], ["2", '"', "@"], ["3", "*", "#"], ["4", "\u00E7", "\u00B0"], ["5", "%", "\u00A7"], ["6", "&", "\u00AC"], ["7", "/", "|"], ["8", "(", "\u00A2"], ["9", ")"], ["0", "="], ["'", "?", "\u00B4"], ["^", "`", "~"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00FC", "\u00E8", "["], ["\u00A8", "!", "]"], ["$", "\u00A3", "}"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00F6", "\u00E9"], ["\u00E4", "\u00E0", "{"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["de-CH"] };

  this.VKI_layout['Shqip'] = {
    'name': "Albanian", 'keys': [
      [["\\", "|"], ["1", "!", "~"], ["2", '"', "\u02C7"], ["3", "#", "^"], ["4", "$", "\u02D8"], ["5", "%", "\u00B0"], ["6", "^", "\u02DB"], ["7", "&", "`"], ["8", "*", "\u02D9"], ["9", "(", "\u00B4"], ["0", ")", "\u02DD"], ["-", "_", "\u00A8"], ["=", "+", "\u00B8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\\"], ["w", "W", "|"], ["e", "E"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00E7", "\u00C7", "\u00F7"], ["[", "{", "\u00DF"], ["]", "}", "\u00A4"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u0111"], ["d", "D", "\u0110"], ["f", "F", "["], ["g", "G", "]"], ["h", "H"], ["j", "J"], ["k", "K", "\u0142"], ["l", "L", "\u0141"], ["\u00EB", "\u00CB", "$"], ["@", "'", "\u00D7"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V", "@"], ["b", "B", "{"], ["n", "N", "}"], ["m", "M", "\u00A7"], [",", ";", "<"], [".", ":", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["sq"] };

  this.VKI_layout['Sloven\u010dina'] = {
    'name': "Slovak", 'keys': [
      [[";", "\u00b0"], ["+", "1", "~"], ["\u013E", "2", "\u02C7"], ["\u0161", "3", "^"], ["\u010D", "4", "\u02D8"], ["\u0165", "5", "\u00B0"], ["\u017E", "6", "\u02DB"], ["\u00FD", "7", "`"], ["\u00E1", "8", "\u02D9"], ["\u00ED", "9", "\u00B4"], ["\u00E9", "0", "\u02DD"], ["=", "%", "\u00A8"], ["\u00B4", "\u02c7", "\u00B8"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\\"], ["w", "W", "|"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P", "'"], ["\u00FA", "/", "\u00F7"], ["\u00E4", "(", "\u00D7"], ["\u0148", ")", "\u00A4"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S", "\u0111"], ["d", "D", "\u0110"], ["f", "F", "["], ["g", "G", "]"], ["h", "H"], ["j", "J"], ["k", "K", "\u0142"], ["l", "L", "\u0141"], ["\u00F4", '"', "$"], ["\u00A7", "!", "\u00DF"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["&", "*", "<"], ["y", "Y", ">"], ["x", "X", "#"], ["c", "C", "&"], ["v", "V", "@"], ["b", "B", "{"], ["n", "N", "}"], ["m", "M"], [",", "?", "<"], [".", ":", ">"], ["-", "_", "*"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["sk"] };

  this.VKI_layout['Sloven\u0161\u010dina'] = {
    'name': "Slovenian", 'keys': this.VKI_layout['Bosanski'].keys.slice(0), 'lang': ["sl"]
  };

  this.VKI_layout['\u0441\u0440\u043f\u0441\u043a\u0438'] = {
    'name': "Serbian Cyrillic", 'keys': [
      [["`", "~"], ["1", "!"], ["2", '"'], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "&"], ["7", "/"], ["8", "("], ["9", ")"], ["0", "="], ["'", "?"], ["+", "*"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0459", "\u0409"], ["\u045a", "\u040a"], ["\u0435", "\u0415", "\u20ac"], ["\u0440", "\u0420"], ["\u0442", "\u0422"], ["\u0437", "\u0417"], ["\u0443", "\u0423"], ["\u0438", "\u0418"], ["\u043e", "\u041e"], ["\u043f", "\u041f"], ["\u0448", "\u0428"], ["\u0452", "\u0402"], ["\u0436", "\u0416"]],
      [["Caps", "Caps"], ["\u0430", "\u0410"], ["\u0441", "\u0421"], ["\u0434", "\u0414"], ["\u0444", "\u0424"], ["\u0433", "\u0413"], ["\u0445", "\u0425"], ["\u0458", "\u0408"], ["\u043a", "\u041a"], ["\u043b", "\u041b"], ["\u0447", "\u0427"], ["\u045b", "\u040b"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">"], ["\u0455", "\u0405"], ["\u045f", "\u040f"], ["\u0446", "\u0426"], ["\u0432", "\u0412"], ["\u0431", "\u0411"], ["\u043d", "\u041d"], ["\u043c", "\u041c"], [",", ";", "<"], [".", ":", ">"], ["-", "_", "\u00a9"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["sr-Cyrl"] };

  this.VKI_layout['Srpski'] = {
    'name': "Serbian Latin", 'keys': this.VKI_layout['Bosanski'].keys.slice(0), 'lang': ["sr"]
  };

  this.VKI_layout['Suomi'] = {
    'name': "Finnish", 'keys': [
      [["\u00a7", "\u00BD"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00A3"], ["4", "\u00A4", "$"], ["5", "%", "\u20AC"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["+", "?", "\\"], ["\u00B4", "`"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\u00E2", "\u00C2"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T", "\u0167", "\u0166"], ["y", "Y"], ["u", "U"], ["i", "I", "\u00ef", "\u00CF"], ["o", "O", "\u00f5", "\u00D5"], ["p", "P"], ["\u00E5", "\u00C5"], ["\u00A8", "^", "~"], ["'", "*"]],
      [["Caps", "Caps"], ["a", "A", "\u00E1", "\u00C1"], ["s", "S", "\u0161", "\u0160"], ["d", "D", "\u0111", "\u0110"], ["f", "F", "\u01e5", "\u01E4"], ["g", "G", "\u01E7", "\u01E6"], ["h", "H", "\u021F", "\u021e"], ["j", "J"], ["k", "K", "\u01e9", "\u01E8"], ["l", "L"], ["\u00F6", "\u00D6", "\u00F8", "\u00D8"], ["\u00E4", "\u00C4", "\u00E6", "\u00C6"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|"], ["z", "Z", "\u017E", "\u017D"], ["x", "X"], ["c", "C", "\u010d", "\u010C"], ["v", "V", "\u01EF", "\u01EE"], ["b", "B", "\u0292", "\u01B7"], ["n", "N", "\u014B", "\u014A"], ["m", "M", "\u00B5"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [["Alt", "Alt"], [" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fi"] };

  this.VKI_layout['Svenska'] = {
    'name': "Swedish", 'keys': [
      [["\u00a7", "\u00bd"], ["1", "!"], ["2", '"', "@"], ["3", "#", "\u00a3"], ["4", "\u00a4", "$"], ["5", "%", "\u20ac"], ["6", "&"], ["7", "/", "{"], ["8", "(", "["], ["9", ")", "]"], ["0", "=", "}"], ["+", "?", "\\"], ["\u00b4", "`"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00e5", "\u00c5"], ["\u00a8", "^", "~"], ["'", "*"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00f6", "\u00d6"], ["\u00e4", "\u00c4"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M", "\u03bc", "\u039c"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["sv"] };

  this.VKI_layout['Swiss Fran\u00e7ais'] = {
    'name': "Swiss French", 'keys': [
      [["\u00A7", "\u00B0"], ["1", "+", "\u00A6"], ["2", '"', "@"], ["3", "*", "#"], ["4", "\u00E7", "\u00B0"], ["5", "%", "\u00A7"], ["6", "&", "\u00AC"], ["7", "/", "|"], ["8", "(", "\u00A2"], ["9", ")"], ["0", "="], ["'", "?", "\u00B4"], ["^", "`", "~"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u20AC"], ["r", "R"], ["t", "T"], ["z", "Z"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["\u00E8", "\u00FC", "["], ["\u00A8", "!", "]"], ["$", "\u00A3", "}"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u00E9", "\u00F6"], ["\u00E0", "\u00E4", "{"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "\\"], ["y", "Y"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", ";"], [".", ":"], ["-", "_"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["fr-CH"] };

  this.VKI_layout['\u0723\u0718\u072a\u071d\u071d\u0710'] = {
    'name': "Syriac", 'keys': [
      [["\u070f", "\u032e", "\u0651", "\u0651"], ["1", "!", "\u0701", "\u0701"], ["2", "\u030a", "\u0702", "\u0702"], ["3", "\u0325", "\u0703", "\u0703"], ["4", "\u0749", "\u0704", "\u0704"], ["5", "\u2670", "\u0705", "\u0705"], ["6", "\u2671", "\u0708", "\u0708"], ["7", "\u070a", "\u0709", "\u0709"], ["8", "\u00bb", "\u070B", "\u070B"], ["9", ")", "\u070C", "\u070C"], ["0", "(", "\u070D", "\u070D"], ["-", "\u00ab", "\u250C", "\u250C"], ["=", "+", "\u2510", "\u2510"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0714", "\u0730", "\u064E", "\u064E"], ["\u0728", "\u0733", "\u064B", "\u064B"], ["\u0716", "\u0736", "\u064F", "\u064F"], ["\u0729", "\u073A", "\u064C", "\u064C"], ["\u0726", "\u073D", "\u0653", "\u0653"], ["\u071c", "\u0740", "\u0654", "\u0654"], ["\u0725", "\u0741", "\u0747", "\u0747"], ["\u0717", "\u0308", "\u0743", "\u0743"], ["\u071e", "\u0304", "\u0745", "\u0745"], ["\u071a", "\u0307", "\u032D", "\u032D"], ["\u0713", "\u0303"], ["\u0715", "\u074A"], ["\u0706", ":"]],
      [["Caps", "Caps"], ["\u072b", "\u0731", "\u0650", "\u0650"], ["\u0723", "\u0734", "\u064d", "\u064d"], ["\u071d", "\u0737"], ["\u0712", "\u073b", "\u0621", "\u0621"], ["\u0720", "\u073e", "\u0655", "\u0655"], ["\u0710", "\u0711", "\u0670", "\u0670"], ["\u072c", "\u0640", "\u0748", "\u0748"], ["\u0722", "\u0324", "\u0744", "\u0744"], ["\u0721", "\u0331", "\u0746", "\u0746"], ["\u071f", "\u0323"], ["\u071b", "\u0330"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["]", "\u0732"], ["[", "\u0735", "\u0652", "\u0652"], ["\u0724", "\u0738"], ["\u072a", "\u073c", "\u200D"], ["\u0727", "\u073f", "\u200C"], ["\u0700", "\u0739", "\u200E"], [".", "\u0742", "\u200F"], ["\u0718", "\u060c"], ["\u0719", "\u061b"], ["\u0707", "\u061F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["syc"] };

  this.VKI_layout['\u0ba4\u0bae\u0bbf\u0bb4\u0bcd'] = {
    'name': "Tamil", 'keys': [
      [["\u0BCA", "\u0B92"], ["1", "", "\u0BE7"], ["2", "", "\u0BE8"], ["3", "", "\u0BE9"], ["4", "", "\u0BEA"], ["5", "", "\u0BEB"], ["6", "\u0BA4\u0BCD\u0BB0", "\u0BEC"], ["7", "\u0B95\u0BCD\u0BB7", "\u0BED"], ["8", "\u0BB7\u0BCD\u0BB0", "\u0BEE"], ["9", "", "\u0BEF"], ["0", "", "\u0BF0"], ["-", "\u0B83", "\u0BF1"], ["", "", "\u0BF2"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0BCC", "\u0B94"], ["\u0BC8", "\u0B90"], ["\u0BBE", "\u0B86"], ["\u0BC0", "\u0B88"], ["\u0BC2", "\u0B8A"], ["\u0BAA", "\u0BAA"], ["\u0BB9", "\u0B99"], ["\u0B95", "\u0B95"], ["\u0BA4", "\u0BA4"], ["\u0B9C", "\u0B9A"], ["\u0B9F", "\u0B9F"], ["\u0B9E"]],
      [["Caps", "Caps"], ["\u0BCB", "\u0B93"], ["\u0BC7", "\u0B8F"], ["\u0BCD", "\u0B85"], ["\u0BBF", "\u0B87"], ["\u0BC1", "\u0B89"], ["\u0BAA", "\u0BAA"], ["\u0BB0", "\u0BB1"], ["\u0B95", "\u0B95"], ["\u0BA4", "\u0BA4"], ["\u0B9A", "\u0B9A"], ["\u0B9F", "\u0B9F"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0BC6", "\u0B8E"], [""], ["\u0BAE", "\u0BA3"], ["\u0BA8", "\u0BA9"], ["\u0BB5", "\u0BB4"], ["\u0BB2", "\u0BB3"], ["\u0BB8", "\u0BB7"], [",", "\u0BB7"], [".", "\u0BB8\u0BCD\u0BB0\u0BC0"], ["\u0BAF", "\u0BAF"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["ta"] };

  this.VKI_layout['\u0c24\u0c46\u0c32\u0c41\u0c17\u0c41'] = {
    'name': "Telugu", 'keys': [
      [["\u0C4A", "\u0C12"], ["1", "", "\u0C67"], ["2", "", "\u0C68"], ["3", "\u0C4D\u0C30", "\u0C69"], ["4", "", "\u0C6A"], ["5", "\u0C1C\u0C4D\u0C1E", "\u0C6B"], ["6", "\u0C24\u0C4D\u0C30", "\u0C6C"], ["7", "\u0C15\u0C4D\u0C37", "\u0C6D"], ["8", "\u0C36\u0C4D\u0C30", "\u0C6E"], ["9", "(", "\u0C6F"], ["0", ")", "\u0C66"], ["-", "\u0C03"], ["\u0C43", "\u0C0B", "\u0C44"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0C4C", "\u0C14"], ["\u0C48", "\u0C10", "\u0C56"], ["\u0C3E", "\u0C06"], ["\u0C40", "\u0C08", "", "\u0C61"], ["\u0C42", "\u0C0A"], ["\u0C2C"], ["\u0C39", "\u0C19"], ["\u0C17", "\u0C18"], ["\u0C26", "\u0C27"], ["\u0C1C", "\u0C1D"], ["\u0C21", "\u0C22"], ["", "\u0C1E"]],
      [["Caps", "Caps"], ["\u0C4B", "\u0C13"], ["\u0C47", "\u0C0F", "\u0C55"], ["\u0C4D", "\u0C05"], ["\u0C3F", "\u0C07", "", "\u0C0C"], ["\u0C41", "\u0C09"], ["\u0C2A", "\u0C2B"], ["\u0C30", "\u0C31"], ["\u0C15", "\u0C16"], ["\u0C24", "\u0C25"], ["\u0C1A", "\u0C1B"], ["\u0C1F", "\u0C25"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0C46", "\u0C0E"], ["\u0C02", "\u0C01"], ["\u0C2E", "\u0C23"], ["\u0C28", "\u0C28"], ["\u0C35"], ["\u0C32", "\u0C33"], ["\u0C38", "\u0C36"], [",", "\u0C37"], ["."], ["\u0C2F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["te"] };

  this.VKI_layout['Ti\u1ebfng Vi\u1ec7t'] = {
    'name': "Vietnamese", 'keys': [
      [["`", "~", "`", "~"], ["\u0103", "\u0102", "1", "!"], ["\u00E2", "\u00C2", "2", "@"], ["\u00EA", "\u00CA", "3", "#"], ["\u00F4", "\u00D4", "4", "$"], ["\u0300", "\u0300", "5", "%"], ["\u0309", "\u0309", "6", "^"], ["\u0303", "\u0303", "7", "&"], ["\u0301", "\u0301", "8", "*"], ["\u0323", "\u0323", "9", "("], ["\u0111", "\u0110", "0", ")"], ["-", "_", "-", "_"], ["\u20AB", "+", "=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "q", "Q"], ["w", "W", "w", "W"], ["e", "E", "e", "E"], ["r", "R", "r", "R"], ["t", "T", "t", "T"], ["y", "Y", "y", "Y"], ["u", "U", "u", "U"], ["i", "I", "i", "I"], ["o", "O", "o", "O"], ["p", "P", "p", "P"], ["\u01B0", "\u01AF", "[", "{"], ["\u01A1", "\u01A0", "]", "}"], ["\\", "|", "\\", "|"]],
      [["Caps", "Caps"], ["a", "A", "a", "A"], ["s", "S", "s", "S"], ["d", "D", "d", "D"], ["f", "F", "f", "F"], ["g", "G", "g", "G"], ["h", "H", "h", "H"], ["j", "J", "j", "J"], ["k", "K", "k", "K"], ["l", "L", "l", "L"], [";", ":", ";", ":"], ["'", '"', "'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z", "z", "Z"], ["x", "X", "x", "X"], ["c", "C", "c", "C"], ["v", "V", "v", "V"], ["b", "B", "b", "B"], ["n", "N", "n", "N"], ["m", "M", "m", "M"], [",", "<", ",", "<"], [".", ">", ".", ">"], ["/", "?", "/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["vi"] };

  this.VKI_layout['\u0e44\u0e17\u0e22 Kedmanee'] = {
    'name': "Thai Kedmanee", 'keys': [
      [["_", "%"], ["\u0E45", "+"], ["/", "\u0E51"], ["-", "\u0E52"], ["\u0E20", "\u0E53"], ["\u0E16", "\u0E54"], ["\u0E38", "\u0E39"], ["\u0E36", "\u0E3F"], ["\u0E04", "\u0E55"], ["\u0E15", "\u0E56"], ["\u0E08", "\u0E57"], ["\u0E02", "\u0E58"], ["\u0E0A", "\u0E59"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0E46", "\u0E50"], ["\u0E44", '"'], ["\u0E33", "\u0E0E"], ["\u0E1E", "\u0E11"], ["\u0E30", "\u0E18"], ["\u0E31", "\u0E4D"], ["\u0E35", "\u0E4A"], ["\u0E23", "\u0E13"], ["\u0E19", "\u0E2F"], ["\u0E22", "\u0E0D"], ["\u0E1A", "\u0E10"], ["\u0E25", ","], ["\u0E03", "\u0E05"]],
      [["Caps", "Caps"], ["\u0E1F", "\u0E24"], ["\u0E2B", "\u0E06"], ["\u0E01", "\u0E0F"], ["\u0E14", "\u0E42"], ["\u0E40", "\u0E0C"], ["\u0E49", "\u0E47"], ["\u0E48", "\u0E4B"], ["\u0E32", "\u0E29"], ["\u0E2A", "\u0E28"], ["\u0E27", "\u0E0B"], ["\u0E07", "."], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0E1C", "("], ["\u0E1B", ")"], ["\u0E41", "\u0E09"], ["\u0E2D", "\u0E2E"], ["\u0E34", "\u0E3A"], ["\u0E37", "\u0E4C"], ["\u0E17", "?"], ["\u0E21", "\u0E12"], ["\u0E43", "\u0E2C"], ["\u0E1D", "\u0E26"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["th"] };

  this.VKI_layout['\u0e44\u0e17\u0e22 Pattachote'] = {
    'name': "Thai Pattachote", 'keys': [
      [["_", "\u0E3F"], ["=", "+"], ["\u0E52", '"'], ["\u0E53", "/"], ["\u0E54", ","], ["\u0E55", "?"], ["\u0E39", "\u0E38"], ["\u0E57", "_"], ["\u0E58", "."], ["\u0E59", "("], ["\u0E50", ")"], ["\u0E51", "-"], ["\u0E56", "%"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0E47", "\u0E4A"], ["\u0E15", "\u0E24"], ["\u0E22", "\u0E46"], ["\u0E2D", "\u0E0D"], ["\u0E23", "\u0E29"], ["\u0E48", "\u0E36"], ["\u0E14", "\u0E1D"], ["\u0E21", "\u0E0B"], ["\u0E27", "\u0E16"], ["\u0E41", "\u0E12"], ["\u0E43", "\u0E2F"], ["\u0E0C", "\u0E26"], ["\uF8C7", "\u0E4D"]],
      [["Caps", "Caps"], ["\u0E49", "\u0E4B"], ["\u0E17", "\u0E18"], ["\u0E07", "\u0E33"], ["\u0E01", "\u0E13"], ["\u0E31", "\u0E4C"], ["\u0E35", "\u0E37"], ["\u0E32", "\u0E1C"], ["\u0E19", "\u0E0A"], ["\u0E40", "\u0E42"], ["\u0E44", "\u0E06"], ["\u0E02", "\u0E11"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0E1A", "\u0E0E"], ["\u0E1B", "\u0E0F"], ["\u0E25", "\u0E10"], ["\u0E2B", "\u0E20"], ["\u0E34", "\u0E31"], ["\u0E04", "\u0E28"], ["\u0E2A", "\u0E2E"], ["\u0E30", "\u0E1F"], ["\u0E08", "\u0E09"], ["\u0E1E", "\u0E2C"], ["Shift", "Shift"]],
      [[" ", " "]]
    ]};

  this.VKI_layout['\u0422\u0430\u0442\u0430\u0440\u0447\u0430'] = {
    'name': "Tatar", 'keys': [
      [["\u04BB", "\u04BA", "\u0451", "\u0401"], ["1", "!"], ["2", '"', "@"], ["3", "\u2116", "#"], ["4", ";", "$"], ["5", "%"], ["6", ":"], ["7", "?", "["], ["8", "*", "]"], ["9", "(", "{"], ["0", ")", "}"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u04E9", "\u04E8", "\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u04D9", "\u04D8", "\u0449", "\u0429"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u04AF", "\u04AE", "\u044A", "\u042A"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u044B", "\u042B"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u04A3", "\u04A2", "\u0436", "\u0416"], ["\u044D", "\u042D", "'"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0491", "\u0490"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u0497", "\u0496", "\u044C", "\u042C"], ["\u0431", "\u0411", "<"], ["\u044E", "\u042E", ">"], [".", ","], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["tt"] };

  this.VKI_layout['T\u00fcrk\u00e7e F'] = {
    'name': "Turkish F", 'keys': [
      [['+', "*", "\u00ac"], ["1", "!", "\u00b9", "\u00a1"], ["2", '"', "\u00b2"], ["3", "^", "#", "\u00b3"], ["4", "$", "\u00bc", "\u00a4"], ["5", "%", "\u00bd"], ["6", "&", "\u00be"], ["7", "'", "{"], ["8", "(", '['], ["9", ")", ']'], ["0", "=", "}"], ["/", "?", "\\", "\u00bf"], ["-", "_", "|"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["f", "F", "@"], ["g", "G"], ["\u011f", "\u011e"], ["\u0131", "I", "\u00b6", "\u00ae"], ["o", "O"], ["d", "D", "\u00a5"], ["r", "R"], ["n", "N"], ["h", "H", "\u00f8", "\u00d8"], ["p", "P", "\u00a3"], ["q", "Q", "\u00a8"], ["w", "W", "~"], ["x", "X", "`"]],
      [["Caps", "Caps"], ["u", "U", "\u00e6", "\u00c6"], ["i", "\u0130", "\u00df", "\u00a7"], ["e", "E", "\u20ac"], ["a", "A", " ", "\u00aa"], ["\u00fc", "\u00dc"], ["t", "T"], ["k", "K"], ["m", "M"], ["l", "L"], ["y", "Y", "\u00b4"], ["\u015f", "\u015e"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|", "\u00a6"], ["j", "J", "\u00ab", "<"], ["\u00f6", "\u00d6", "\u00bb", ">"], ["v", "V", "\u00a2", "\u00a9"], ["c", "C"], ["\u00e7", "\u00c7"], ["z", "Z"], ["s", "S", "\u00b5", "\u00ba"], ["b", "B", "\u00d7"], [".", ":", "\u00f7"], [",", ";", "-"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "],  ["AltGr", "AltGr"]]
    ]};

  this.VKI_layout['T\u00fcrk\u00e7e Q'] = {
    'name': "Turkish Q", 'keys': [
      [['"', "\u00e9", "<"], ["1", "!", ">"], ["2", "'", "\u00a3"], ["3", "^", "#"], ["4", "+", "$"], ["5", "%", "\u00bd"], ["6", "&"], ["7", "/", "{"], ["8", "(", '['], ["9", ")", ']'], ["0", "=", "}"], ["*", "?", "\\"], ["-", "_", "|"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "@"], ["w", "W"], ["e", "E", "\u20ac"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["\u0131", "I", "i", "\u0130"], ["o", "O"], ["p", "P"], ["\u011f", "\u011e", "\u00a8"], ["\u00fc", "\u00dc", "~"], [",", ";", "`"]],
      [["Caps", "Caps"], ["a", "A", "\u00e6", "\u00c6"], ["s", "S", "\u00df"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], ["\u015f", "\u015e", "\u00b4"], ["i", "\u0130"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["<", ">", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], ["\u00f6", "\u00d6"], ["\u00e7", "\u00c7"], [".", ":"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "],  ["AltGr", "AltGr"]]
    ], 'lang': ["tr"] };

  this.VKI_layout['\u0423\u043a\u0440\u0430\u0457\u043d\u0441\u044c\u043a\u0430'] = {
    'name': "Ukrainian", 'keys': [
      [["\u00b4", "~"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u0449", "\u0429"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u0457", "\u0407"], ["\u0491", "\u0490"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u0456", "\u0406"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u0454", "\u0404"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044C", "\u042C"], ["\u0431", "\u0411"], ["\u044E", "\u042E"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["uk"] };

  this.VKI_layout['United Kingdom'] = {
    'name': "United Kingdom", 'keys': [
      [["`", "\u00ac", "\u00a6"], ["1", "!"], ["2", '"'], ["3", "\u00a3"], ["4", "$", "\u20ac"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E", "\u00e9", "\u00c9"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U", "\u00fa", "\u00da"], ["i", "I", "\u00ed", "\u00cd"], ["o", "O", "\u00f3", "\u00d3"], ["p", "P"], ["[", "{"], ["]", "}"], ["#", "~"]],
      [["Caps", "Caps"], ["a", "A", "\u00e1", "\u00c1"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":"], ["'", "@"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\\", "|"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["AltGr", "AltGr"]]
    ], 'lang': ["en-gb"] };

  this.VKI_layout['\u0627\u0631\u062f\u0648'] = {
    'name': "Urdu", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "\u066A"], ["6", "^"], ["7", "\u06D6"], ["8", "\u066D"], ["9", ")"], ["0", "("], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0637", "\u0638"], ["\u0635", "\u0636"], ["\u06be", "\u0630"], ["\u062f", "\u0688"], ["\u0679", "\u062B"], ["\u067e", "\u0651"], ["\u062a", "\u06C3"], ["\u0628", "\u0640"], ["\u062c", "\u0686"], ["\u062d", "\u062E"], ["]", "}"], ["[", "{"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u0645", "\u0698"], ["\u0648", "\u0632"], ["\u0631", "\u0691"], ["\u0646", "\u06BA"], ["\u0644", "\u06C2"], ["\u06c1", "\u0621"], ["\u0627", "\u0622"], ["\u06A9", "\u06AF"], ["\u06CC", "\u064A"], ["\u061b", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0642", "\u200D"], ["\u0641", "\u200C"], ["\u06D2", "\u06D3"], ["\u0633", "\u200E"], ["\u0634", "\u0624"], ["\u063a", "\u0626"], ["\u0639", "\u200F"], ["\u060C", ">"], ["\u06D4", "<"], ["/", "\u061F"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["ur"] };

  this.VKI_layout['\u0627\u0631\u062f\u0648 Phonetic'] = {
    'name': "Urdu Phonetic", 'keys': [
      [["\u064D", "\u064B", "~"], ["\u06F1", "1", "!"], ["\u06F2", "2", "@"], ["\u06F3", "3", "#"], ["\u06F4", "4", "$"], ["\u06F5", "5", "\u066A"], ["\u06F6", "6", "^"], ["\u06F7", "7", "&"], ["\u06F8", "8", "*"], ["\u06F9", "9", "("], ["\u06F0", "0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0642", "\u0652"], ["\u0648", "\u0651", "\u0602"], ["\u0639", "\u0670", "\u0656"], ["\u0631", "\u0691", "\u0613"], ["\u062A", "\u0679", "\u0614"], ["\u06D2", "\u064E", "\u0601"], ["\u0621", "\u0626", "\u0654"], ["\u06CC", "\u0650", "\u0611"], ["\u06C1", "\u06C3"], ["\u067E", "\u064F", "\u0657"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u0627", "\u0622", "\uFDF2"], ["\u0633", "\u0635", "\u0610"], ["\u062F", "\u0688", "\uFDFA"], ["\u0641"], ["\u06AF", "\u063A"], ["\u062D", "\u06BE", "\u0612"], ["\u062C", "\u0636", "\uFDFB"], ["\u06A9", "\u062E"], ["\u0644"], ["\u061B", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u0632", "\u0630", "\u060F"], ["\u0634", "\u0698", "\u060E"], ["\u0686", "\u062B", "\u0603"], ["\u0637", "\u0638"], ["\u0628", "", "\uFDFD"], ["\u0646", "\u06BA", "\u0600"], ["\u0645", "\u0658"], ["\u060C", "", "<"], ["\u06D4", "\u066B", ">"], ["/", "\u061F"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ]};

  this.VKI_layout['US Standard'] = {
    'name': "US Standard", 'keys': [
      [["`", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", "("], ["0", ")"], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q"], ["w", "W"], ["e", "E"], ["r", "R"], ["t", "T"], ["y", "Y"], ["u", "U"], ["i", "I"], ["o", "O"], ["p", "P"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["a", "A"], ["s", "S"], ["d", "D"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z"], ["x", "X"], ["c", "C"], ["v", "V"], ["b", "B"], ["n", "N"], ["m", "M"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["en-us"] };

   this.VKI_layout['US International'] = {
    'name': "US International", 'keys': [
      [["`", "~"], ["1", "!", "\u00a1", "\u00b9"], ["2", "@", "\u00b2"], ["3", "#", "\u00b3"], ["4", "$", "\u00a4", "\u00a3"], ["5", "%", "\u20ac"], ["6", "^", "\u00bc"], ["7", "&", "\u00bd"], ["8", "*", "\u00be"], ["9", "(", "\u2018"], ["0", ")", "\u2019"], ["-", "_", "\u00a5"], ["=", "+", "\u00d7", "\u00f7"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["q", "Q", "\u00e4", "\u00c4"], ["w", "W", "\u00e5", "\u00c5"], ["e", "E", "\u00e9", "\u00c9"], ["r", "R", "\u00ae"], ["t", "T", "\u00fe", "\u00de"], ["y", "Y", "\u00fc", "\u00dc"], ["u", "U", "\u00fa", "\u00da"], ["i", "I", "\u00ed", "\u00cd"], ["o", "O", "\u00f3", "\u00d3"], ["p", "P", "\u00f6", "\u00d6"], ["[", "{", "\u00ab"], ["]", "}", "\u00bb"], ["\\", "|", "\u00ac", "\u00a6"]],
      [["Caps", "Caps"], ["a", "A", "\u00e1", "\u00c1"], ["s", "S", "\u00df", "\u00a7"], ["d", "D", "\u00f0", "\u00d0"], ["f", "F"], ["g", "G"], ["h", "H"], ["j", "J"], ["k", "K"], ["l", "L", "\u00f8", "\u00d8"], [";", ":", "\u00b6", "\u00b0"], ["'", '"', "\u00b4", "\u00a8"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["z", "Z", "\u00e6", "\u00c6"], ["x", "X"], ["c", "C", "\u00a9", "\u00a2"], ["v", "V"], ["b", "B"], ["n", "N", "\u00f1", "\u00d1"], ["m", "M", "\u00b5"], [",", "<", "\u00e7", "\u00c7"], [".", ">"], ["/", "?", "\u00bf"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["en"] };

  this.VKI_layout['\u040e\u0437\u0431\u0435\u043a\u0447\u0430'] = {
    'name': "Uzbek Cyrillic", 'keys': [
      [["\u0451", "\u0401"], ["1", "!"], ["2", '"'], ["3", "\u2116"], ["4", ";"], ["5", "%"], ["6", ":"], ["7", "?"], ["8", "*"], ["9", "("], ["0", ")"], ["\u0493", "\u0492"], ["\u04B3", "\u04B2"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u0439", "\u0419"], ["\u0446", "\u0426"], ["\u0443", "\u0423"], ["\u043A", "\u041A"], ["\u0435", "\u0415"], ["\u043D", "\u041D"], ["\u0433", "\u0413"], ["\u0448", "\u0428"], ["\u045E", "\u040E"], ["\u0437", "\u0417"], ["\u0445", "\u0425"], ["\u044A", "\u042A"], ["\\", "/"]],
      [["Caps", "Caps"], ["\u0444", "\u0424"], ["\u049B", "\u049A"], ["\u0432", "\u0412"], ["\u0430", "\u0410"], ["\u043F", "\u041F"], ["\u0440", "\u0420"], ["\u043E", "\u041E"], ["\u043B", "\u041B"], ["\u0434", "\u0414"], ["\u0436", "\u0416"], ["\u044D", "\u042D"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u044F", "\u042F"], ["\u0447", "\u0427"], ["\u0441", "\u0421"], ["\u043C", "\u041C"], ["\u0438", "\u0418"], ["\u0442", "\u0422"], ["\u044C", "\u042C"], ["\u0431", "\u0411"], ["\u044E", "\u042E"], [".", ","], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["uz"] };

  this.VKI_layout['\u05d9\u05d9\u05b4\u05d3\u05d9\u05e9'] = { // from http://www.yv.org/uyip/hebyidkbd.txt http://uyip.org/keyboards.html
    'name': "Yiddish", 'keys': [
      [[";", "~", "\u05B0"], ["1", "!", "\u05B1"], ["2", "@", "\u05B2"], ["3", "#", "\u05B3"], ["4", "$", "\u05B4"], ["5", "%", "\u05B5"], ["6", "^", "\u05B6"], ["7", "*", "\u05B7"], ["8", "&", "\u05B8"], ["9", "(", "\u05C2"], ["0", ")", "\u05C1"], ["-", "_", "\u05B9"], ["=", "+", "\u05BC"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["/", "\u201F", "\u201F"], ["'", "\u201E", "\u201E"], ["\u05E7", "`", "`"], ["\u05E8", "\uFB2F", "\uFB2F"], ["\u05D0", "\uFB2E", "\uFB2E"], ["\u05D8", "\u05F0", "\u05F0"], ["\u05D5", "\uFB35", "\uFB35"], ["\u05DF", "\uFB4B", "\uFB4B"], ["\u05DD", "\uFB4E", "\uFB4E"], ["\u05E4", "\uFB44", "\uFB44"], ["[", "{", "\u05BD"], ["]", "}", "\u05BF"], ["\\", "|", "\u05BB"]],
      [["Caps", "Caps"], ["\u05E9", "\uFB2A", "\uFB2A"], ["\u05D3", "\uFB2B", "\uFB2B"], ["\u05D2"], ["\u05DB", "\uFB3B", "\uFB3B"], ["\u05E2", "\u05F1", "\u05F1"], ["\u05D9", "\uFB1D", "\uFB1D"], ["\u05D7", "\uFF1F", "\uFF1F"], ["\u05DC", "\u05F2", "\u05F2"], ["\u05DA"], ["\u05E3", ":", "\u05C3"], [",", '"', "\u05C0"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u05D6", "\u2260", "\u2260"], ["\u05E1", "\uFB4C", "\uFB4C"], ["\u05D1", "\uFB31", "\uFB31"], ["\u05D4", "\u05BE", "\u05BE"], ["\u05E0", "\u2013", "\u2013"], ["\u05DE", "\u2014", "\u2014"], ["\u05E6", "\uFB4A", "\uFB4A"], ["\u05EA", "<", "\u05F3"], ["\u05E5", ">", "\u05F4"], [".", "?", "\u20AA"], ["Shift", "Shift"]],
      [[" ", " "], ["Alt", "Alt"]]
    ], 'lang': ["yi"] };

  this.VKI_layout['\u05d9\u05d9\u05b4\u05d3\u05d9\u05e9 \u05dc\u05e2\u05d1\u05d8'] = { // from http://jidysz.net/ 
    'name': "Yiddish (Yidish Lebt)", 'keys': [
      [[";", "~"], ["1", "!", "\u05B2", "\u05B2"], ["2", "@", "\u05B3", "\u05B3"], ["3", "#", "\u05B1", "\u05B1"], ["4", "$", "\u05B4", "\u05B4"], ["5", "%", "\u05B5", "\u05B5"], ["6", "^", "\u05B7", "\u05B7"], ["7", "&", "\u05B8", "\u05B8"], ["8", "*", "\u05BB", "\u05BB"], ["9", ")", "\u05B6", "\u05B6"], ["0", "(", "\u05B0", "\u05B0"], ["-", "_", "\u05BF", "\u05BF"], ["=", "+", "\u05B9", "\u05B9"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["/", "", "\u05F4", "\u05F4"], ["'", "", "\u05F3", "\u05F3"], ["\u05E7", "", "\u20AC"], ["\u05E8"], ["\u05D0", "", "\u05D0\u05B7", "\uFB2E"], ["\u05D8", "", "\u05D0\u05B8", "\uFB2F"], ["\u05D5", "\u05D5\u05B9", "\u05D5\u05BC", "\uFB35"], ["\u05DF", "", "\u05D5\u05D5", "\u05F0"], ["\u05DD", "", "\u05BC"], ["\u05E4", "", "\u05E4\u05BC", "\uFB44"], ["]", "}", "\u201E", "\u201D"], ["[", "{", "\u201A", "\u2019"], ["\\", "|", "\u05BE", "\u05BE"]],
      [["Caps", "Caps"], ["\u05E9", "\u05E9\u05C1", "\u05E9\u05C2", "\uFB2B"], ["\u05D3", "", "\u20AA"], ["\u05D2", "\u201E"], ["\u05DB", "", "\u05DB\u05BC", "\uFB3B"], ["\u05E2", "", "", "\uFB20"], ["\u05D9", "", "\u05D9\u05B4", "\uFB1D"], ["\u05D7", "", "\u05F2\u05B7", "\uFB1F"], ["\u05DC", "\u05DC\u05B9", "\u05D5\u05D9", "\u05F1"], ["\u05DA", "", "", "\u05F2"], ["\u05E3", ":", "\u05E4\u05BF", "\uFB4E"], [",", '"', ";", "\u05B2"], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u05D6", "", "\u2013", "\u2013"], ["\u05E1", "", "\u2014", "\u2014"], ["\u05D1", "\u05DC\u05B9", "\u05D1\u05BF", "\uFB4C"], ["\u05D4", "", "\u201D", "\u201C"], ["\u05E0", "", "\u059C", "\u059E"], ["\u05DE", "", "\u2019", "\u2018"], ["\u05E6", "", "\u05E9\u05C1", "\uFB2A"], ["\u05EA", ">", "\u05EA\u05BC", "\uFB4A"], ["\u05E5", "<"], [".", "?", "\u2026"], ["Shift", "Shift"]],
      [[" ", " ", " ", " "], ["Alt", "Alt"]]
    ], 'lang': ["yi"] };

  this.VKI_layout['\u4e2d\u6587\u6ce8\u97f3\u7b26\u53f7'] = {
    'name': "Chinese Bopomofo IME", 'keys': [
      [["\u20AC", "~"], ["\u3105", "!"], ["\u3109", "@"], ["\u02C7", "#"], ["\u02CB", "$"], ["\u3113", "%"], ["\u02CA", "^"], ["\u02D9", "&"], ["\u311A", "*"], ["\u311E", ")"], ["\u3122", "("], ["\u3126", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u3106", "q"], ["\u310A", "w"], ["\u310D", "e"], ["\u3110", "r"], ["\u3114", "t"], ["\u3117", "y"], ["\u3127", "u"], ["\u311B", "i"], ["\u311F", "o"], ["\u3123", "p"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u3107", "a"], ["\u310B", "s"], ["\u310E", "d"], ["\u3111", "f"], ["\u3115", "g"], ["\u3118", "h"], ["\u3128", "j"], ["\u311C", "k"], ["\u3120", "l"], ["\u3124", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\u3108", "z"], ["\u310C", "x"], ["\u310F", "c"], ["\u3112", "v"], ["\u3116", "b"], ["\u3119", "n"], ["\u3129", "m"], ["\u311D", "<"], ["\u3121", ">"], ["\u3125", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["zh-Bopo"] };

  this.VKI_layout['\u4e2d\u6587\u4ed3\u9889\u8f93\u5165\u6cd5'] = {
    'name': "Chinese Cangjie IME", 'keys': [
      [["\u20AC", "~"], ["1", "!"], ["2", "@"], ["3", "#"], ["4", "$"], ["5", "%"], ["6", "^"], ["7", "&"], ["8", "*"], ["9", ")"], ["0", "("], ["-", "_"], ["=", "+"], ["Bksp", "Bksp"]],
      [["Tab", "Tab"], ["\u624B", "q"], ["\u7530", "w"], ["\u6C34", "e"], ["\u53E3", "r"], ["\u5EFF", "t"], ["\u535C", "y"], ["\u5C71", "u"], ["\u6208", "i"], ["\u4EBA", "o"], ["\u5FC3", "p"], ["[", "{"], ["]", "}"], ["\\", "|"]],
      [["Caps", "Caps"], ["\u65E5", "a"], ["\u5C38", "s"], ["\u6728", "d"], ["\u706B", "f"], ["\u571F", "g"], ["\u7AF9", "h"], ["\u5341", "j"], ["\u5927", "k"], ["\u4E2D", "l"], [";", ":"], ["'", '"'], ["Enter", "Enter"]],
      [["Shift", "Shift"], ["\uFF3A", "z"], ["\u96E3", "x"], ["\u91D1", "c"], ["\u5973", "v"], ["\u6708", "b"], ["\u5F13", "n"], ["\u4E00", "m"], [",", "<"], [".", ">"], ["/", "?"], ["Shift", "Shift"]],
      [[" ", " "]]
    ], 'lang': ["zh"] };


  
  this.VKI_deadkey = {};

  // - Lay out each dead key set as an object of property/value
  //   pairs.  The rows below are wrapped so uppercase letters are
  //   below their lowercase equivalents.
  //
  // - The property name is the letter pressed after the diacritic.
  //   The property value is the letter this key-combo will generate.
  //
  // - Note that if you have created a new keyboard layout and want
  //   it included in the distributed script, PLEASE TELL ME if you
  //   have added additional dead keys to the ones below.

  this.VKI_deadkey['"'] = this.VKI_deadkey['\u00a8'] = this.VKI_deadkey['\u309B'] = { // Umlaut / Diaeresis / Greek Dialytika / Hiragana/Katakana Voiced Sound Mark
    'a': "\u00e4", 'e': "\u00eb", 'i': "\u00ef", 'o': "\u00f6", 'u': "\u00fc", 'y': "\u00ff", '\u03b9': "\u03ca", '\u03c5': "\u03cb", '\u016B': "\u01D6", '\u00FA': "\u01D8", '\u01D4': "\u01DA", '\u00F9': "\u01DC",
    'A': "\u00c4", 'E': "\u00cb", 'I': "\u00cf", 'O': "\u00d6", 'U': "\u00dc", 'Y': "\u0178", '\u0399': "\u03aa", '\u03a5': "\u03ab", '\u016A': "\u01D5", '\u00DA': "\u01D7", '\u01D3': "\u01D9", '\u00D9': "\u01DB",
    '\u304b': "\u304c", '\u304d': "\u304e", '\u304f': "\u3050", '\u3051': "\u3052", '\u3053': "\u3054", '\u305f': "\u3060", '\u3061': "\u3062", '\u3064': "\u3065", '\u3066': "\u3067", '\u3068': "\u3069",
    '\u3055': "\u3056", '\u3057': "\u3058", '\u3059': "\u305a", '\u305b': "\u305c", '\u305d': "\u305e", '\u306f': "\u3070", '\u3072': "\u3073", '\u3075': "\u3076", '\u3078': "\u3079", '\u307b': "\u307c",
    '\u30ab': "\u30ac", '\u30ad': "\u30ae", '\u30af': "\u30b0", '\u30b1': "\u30b2", '\u30b3': "\u30b4", '\u30bf': "\u30c0", '\u30c1': "\u30c2", '\u30c4': "\u30c5", '\u30c6': "\u30c7", '\u30c8': "\u30c9",
    '\u30b5': "\u30b6", '\u30b7': "\u30b8", '\u30b9': "\u30ba", '\u30bb': "\u30bc", '\u30bd': "\u30be", '\u30cf': "\u30d0", '\u30d2': "\u30d3", '\u30d5': "\u30d6", '\u30d8': "\u30d9", '\u30db': "\u30dc"
  };
  this.VKI_deadkey['~'] = { // Tilde / Stroke
    'a': "\u00e3", 'l': "\u0142", 'n': "\u00f1", 'o': "\u00f5",
    'A': "\u00c3", 'L': "\u0141", 'N': "\u00d1", 'O': "\u00d5"
  };
  this.VKI_deadkey['^'] = { // Circumflex
    'a': "\u00e2", 'e': "\u00ea", 'i': "\u00ee", 'o': "\u00f4", 'u': "\u00fb", 'w': "\u0175", 'y': "\u0177",
    'A': "\u00c2", 'E': "\u00ca", 'I': "\u00ce", 'O': "\u00d4", 'U': "\u00db", 'W': "\u0174", 'Y': "\u0176"
  };
  this.VKI_deadkey['\u02c7'] = { // Baltic caron
    'c': "\u010D", 'd': "\u010f", 'e': "\u011b", 's': "\u0161", 'l': "\u013e", 'n': "\u0148", 'r': "\u0159", 't': "\u0165", 'u': "\u01d4", 'z': "\u017E", '\u00fc': "\u01da",
    'C': "\u010C", 'D': "\u010e", 'E': "\u011a", 'S': "\u0160", 'L': "\u013d", 'N': "\u0147", 'R': "\u0158", 'T': "\u0164", 'U': "\u01d3", 'Z': "\u017D", '\u00dc': "\u01d9"
  };
  this.VKI_deadkey['\u02d8'] = { // Romanian and Turkish breve
    'a': "\u0103", 'g': "\u011f",
    'A': "\u0102", 'G': "\u011e"
  };
  this.VKI_deadkey['-'] = this.VKI_deadkey['\u00af'] = { // Macron
    'a': "\u0101", 'e': "\u0113", 'i': "\u012b", 'o': "\u014d", 'u': "\u016B", 'y': "\u0233", '\u00fc': "\u01d6",
    'A': "\u0100", 'E': "\u0112", 'I': "\u012a", 'O': "\u014c", 'U': "\u016A", 'Y': "\u0232", '\u00dc': "\u01d5"
  };
  this.VKI_deadkey['`'] = { // Grave
    'a': "\u00e0", 'e': "\u00e8", 'i': "\u00ec", 'o': "\u00f2", 'u': "\u00f9", '\u00fc': "\u01dc",
    'A': "\u00c0", 'E': "\u00c8", 'I': "\u00cc", 'O': "\u00d2", 'U': "\u00d9", '\u00dc': "\u01db"
  };
  this.VKI_deadkey["'"] = this.VKI_deadkey['\u00b4'] = this.VKI_deadkey['\u0384'] = { // Acute / Greek Tonos
    'a': "\u00e1", 'e': "\u00e9", 'i': "\u00ed", 'o': "\u00f3", 'u': "\u00fa", 'y': "\u00fd", '\u03b1': "\u03ac", '\u03b5': "\u03ad", '\u03b7': "\u03ae", '\u03b9': "\u03af", '\u03bf': "\u03cc", '\u03c5': "\u03cd", '\u03c9': "\u03ce", '\u00fc': "\u01d8",
    'A': "\u00c1", 'E': "\u00c9", 'I': "\u00cd", 'O': "\u00d3", 'U': "\u00da", 'Y': "\u00dd", '\u0391': "\u0386", '\u0395': "\u0388", '\u0397': "\u0389", '\u0399': "\u038a", '\u039f': "\u038c", '\u03a5': "\u038e", '\u03a9': "\u038f", '\u00dc': "\u01d7"
  };
  this.VKI_deadkey['\u02dd'] = { // Hungarian Double Acute Accent
    'o': "\u0151", 'u': "\u0171",
    'O': "\u0150", 'U': "\u0170"
  };
  this.VKI_deadkey['\u0385'] = { // Greek Dialytika + Tonos
    '\u03b9': "\u0390", '\u03c5': "\u03b0"
  };
  this.VKI_deadkey['\u00b0'] = this.VKI_deadkey['\u00ba'] = { // Ring
    'a': "\u00e5", 'u': "\u016f",
    'A': "\u00c5", 'U': "\u016e"
  };
  this.VKI_deadkey['\u02DB'] = { // Ogonek
    'a': "\u0106", 'e': "\u0119", 'i': "\u012f", 'o': "\u01eb", 'u': "\u0173", 'y': "\u0177",
    'A': "\u0105", 'E': "\u0118", 'I': "\u012e", 'O': "\u01ea", 'U': "\u0172", 'Y': "\u0176"
  };
  this.VKI_deadkey['\u02D9'] = { // Dot-above
    'c': "\u010B", 'e': "\u0117", 'g': "\u0121", 'z': "\u017C",
    'C': "\u010A", 'E': "\u0116", 'G': "\u0120", 'Z': "\u017B"
  };
  this.VKI_deadkey['\u00B8'] = this.VKI_deadkey['\u201a'] = { // Cedilla
    'c': "\u00e7", 's': "\u015F",
    'C': "\u00c7", 'S': "\u015E"
  };
  this.VKI_deadkey[','] = { // Comma
    's': (this.VKI_isIElt8) ? "\u015F" : "\u0219", 't': (this.VKI_isIElt8) ? "\u0163" : "\u021B",
    'S': (this.VKI_isIElt8) ? "\u015E" : "\u0218", 'T': (this.VKI_isIElt8) ? "\u0162" : "\u021A"
  };
  this.VKI_deadkey['\u3002'] = { // Hiragana/Katakana Point
    '\u306f': "\u3071", '\u3072': "\u3074", '\u3075': "\u3077", '\u3078': "\u307a", '\u307b': "\u307d",
    '\u30cf': "\u30d1", '\u30d2': "\u30d4", '\u30d5': "\u30d7", '\u30d8': "\u30da", '\u30db': "\u30dd"
  };


  
  this.VKI_symbol = {
    '\u00a0': "NB\nSP", '\u200b': "ZW\nSP", '\u200c': "ZW\nNJ", '\u200d': "ZW\nJ"
  };


  
  this.VKI_numpad = [
    [["$"], ["\u00a3"], ["\u20ac"], ["\u00a5"]],
    [["7"], ["8"], ["9"], ["/"]],
    [["4"], ["5"], ["6"], ["*"]],
    [["1"], ["2"], ["3"], ["-"]],
    [["0"], ["."], ["="], ["+"]]
  ];


  
  VKI_attach = function(elem) {
    if (elem.getAttribute("VKI_attached")) return false;
    if (self.VKI_imageURI) {
      var keybut = document.createElement('img');
          keybut.src = self.VKI_imageURI;
          keybut.alt = self.VKI_i18n['01'];
          keybut.className = "keyboardInputInitiator";
          keybut.title = self.VKI_i18n['01'];
          keybut.elem = elem;
          keybut.onclick = function(e) {
            e = e || event;
            if (e.stopPropagation) { e.stopPropagation(); } else e.cancelBubble = true;
            self.VKI_show(this.elem);
          };
      elem.parentNode.insertBefore(keybut, (elem.dir == "rtl") ? elem : elem.nextSibling);
    } else {
      elem.onfocus = function() {
        if (self.VKI_target != this) {
          if (self.VKI_target) self.VKI_close();
          self.VKI_show(this);
        }
      };
      elem.onclick = function() {
        if (!self.VKI_target) self.VKI_show(this);
      }
    }
    elem.setAttribute("VKI_attached", 'true');
    if (self.VKI_isIE) {
      elem.onclick = elem.onselect = elem.onkeyup = function(e) {
        if ((e || event).type != "keyup" || !this.readOnly)
          this.range = document.selection.createRange();
      };
    }
    VKI_addListener(elem, 'click', function(e) {
      if (self.VKI_target == this) {
        e = e || event;
        if (e.stopPropagation) { e.stopPropagation(); } else e.cancelBubble = true;
      } return false;
    }, false);
    if (self.VKI_isMoz)
      elem.addEventListener('blur', function() { this.setAttribute('_scrollTop', this.scrollTop); }, false);
  };


  
  function VKI_buildKeyboardInputs() {
    var inputElems = [
      document.getElementsByTagName('input'),
      document.getElementsByTagName('textarea')
    ];
    for (var x = 0, elem; elem = inputElems[x++];)
      for (var y = 0, ex; ex = elem[y++];)
        if (ex.nodeName == "TEXTAREA" || ex.type == "text" || ex.type == "password")
          if (ex.className.indexOf("keyboardInput") > -1) VKI_attach(ex);

    VKI_addListener(document.documentElement, 'click', function(e) { self.VKI_close(); }, false);
  }


  
  function VKI_mouseEvents(elem) {
    if (elem.nodeName == "TD") {
      if (!elem.click) elem.click = function() {
        var evt = this.ownerDocument.createEvent('MouseEvents');
        evt.initMouseEvent('click', true, true, this.ownerDocument.defaultView, 1, 0, 0, 0, 0, false, false, false, false, 0, null);
        this.dispatchEvent(evt);
      };
      elem.VKI_clickless = 0;
      VKI_addListener(elem, 'dblclick', function() { return false; }, false);
    }
    VKI_addListener(elem, 'mouseover', function() {
      if (this.nodeName == "TD" && self.VKI_clickless) {
        var _self = this;
        clearTimeout(this.VKI_clickless);
        this.VKI_clickless = setTimeout(function() { _self.click(); }, self.VKI_clickless);
      }
      if (self.VKI_isIE) this.className += " hover";
    }, false);
    VKI_addListener(elem, 'mouseout', function() {
      if (this.nodeName == "TD") clearTimeout(this.VKI_clickless);
      if (self.VKI_isIE) this.className = this.className.replace(/ ?(hover|pressed) ?/g, "");
    }, false);
    VKI_addListener(elem, 'mousedown', function() {
      if (this.nodeName == "TD") clearTimeout(this.VKI_clickless);
      if (self.VKI_isIE) this.className += " pressed";
    }, false);
    VKI_addListener(elem, 'mouseup', function() {
      if (this.nodeName == "TD") clearTimeout(this.VKI_clickless);
      if (self.VKI_isIE) this.className = this.className.replace(/ ?pressed ?/g, "");
    }, false);
  }


  
  this.VKI_keyboard = document.createElement('table');
  this.VKI_keyboard.id = "keyboardInputMaster";
  this.VKI_keyboard.dir = "ltr";
  this.VKI_keyboard.cellSpacing = "0";
  this.VKI_keyboard.reflow = function() {
    this.style.width = "50px";
    var foo = this.offsetWidth;
    this.style.width = "";
  };
  VKI_addListener(this.VKI_keyboard, 'click', function(e) {
    e = e || event;
    if (e.stopPropagation) { e.stopPropagation(); } else e.cancelBubble = true;
    return false;
  }, false);

  if (!this.VKI_layout[this.VKI_kt])
    return alert('No keyboard named "' + this.VKI_kt + '"');

  this.VKI_langCode = {};
  var thead = document.createElement('thead');
    var tr = document.createElement('tr');
      var th = document.createElement('th');
          th.colSpan = "2";

        var kbSelect = document.createElement('div');
            kbSelect.title = this.VKI_i18n['02'];
          VKI_addListener(kbSelect, 'click', function() {
            var ol = this.getElementsByTagName('ol')[0];
            if (!ol.style.display) {
                ol.style.display = "block";
              var li = ol.getElementsByTagName('li');
              for (var x = 0, scr = 0; x < li.length; x++) {
                if (VKI_kt == li[x].firstChild.nodeValue) {
                  li[x].className = "selected";
                  scr = li[x].offsetTop - li[x].offsetHeight * 2;
                } else li[x].className = "";
              } setTimeout(function() { ol.scrollTop = scr; }, 0);
            } else ol.style.display = "";
          }, false);
            kbSelect.appendChild(document.createTextNode(this.VKI_kt));
            kbSelect.appendChild(document.createTextNode(this.VKI_isIElt8 ? " \u2193" : " \u25be"));
            kbSelect.langCount = 0;
          var ol = document.createElement('ol');
            for (ktype in this.VKI_layout) {
              if (typeof this.VKI_layout[ktype] == "object") {
                if (!this.VKI_layout[ktype].lang) this.VKI_layout[ktype].lang = [];
                for (var x = 0; x < this.VKI_layout[ktype].lang.length; x++)
                  this.VKI_langCode[this.VKI_layout[ktype].lang[x].toLowerCase().replace(/-/g, "_")] = ktype;
                var li = document.createElement('li');
                    li.title = this.VKI_layout[ktype].name;
                  VKI_addListener(li, 'click', function(e) {
                    e = e || event;
                    if (e.stopPropagation) { e.stopPropagation(); } else e.cancelBubble = true;
                    this.parentNode.style.display = "";
                    self.VKI_kts = self.VKI_kt = kbSelect.firstChild.nodeValue = this.firstChild.nodeValue;
                    self.VKI_buildKeys();
                    self.VKI_position(true);
                  }, false);
                  VKI_mouseEvents(li);
                    li.appendChild(document.createTextNode(ktype));
                  ol.appendChild(li);
                kbSelect.langCount++;
              }
            } kbSelect.appendChild(ol);
          if (kbSelect.langCount > 1) th.appendChild(kbSelect);
        this.VKI_langCode.index = [];
        for (prop in this.VKI_langCode)
          if (prop != "index" && typeof this.VKI_langCode[prop] == "string")
            this.VKI_langCode.index.push(prop);
        this.VKI_langCode.index.sort();
        this.VKI_langCode.index.reverse();

        if (this.VKI_numberPad) {
          var span = document.createElement('span');
              span.appendChild(document.createTextNode("#"));
              span.title = this.VKI_i18n['00'];
            VKI_addListener(span, 'click', function() {
              kbNumpad.style.display = (!kbNumpad.style.display) ? "none" : "";
              self.VKI_position(true);
            }, false);
            VKI_mouseEvents(span);
            th.appendChild(span);
        }

        this.VKI_kbsize = function(e) {
          self.VKI_size = Math.min(5, Math.max(1, self.VKI_size));
          self.VKI_keyboard.className = self.VKI_keyboard.className.replace(/ ?keyboardInputSize\d ?/, "");
          if (self.VKI_size != 2) self.VKI_keyboard.className += " keyboardInputSize" + self.VKI_size;
          self.VKI_position(true);
          if (self.VKI_isOpera) self.VKI_keyboard.reflow();
        };
        if (this.VKI_sizeAdj) {
          var small = document.createElement('small');
              small.title = this.VKI_i18n['10'];
            VKI_addListener(small, 'click', function() {
              --self.VKI_size;
              self.VKI_kbsize();
            }, false);
            VKI_mouseEvents(small);
              small.appendChild(document.createTextNode(this.VKI_isIElt8 ? "\u2193" : "\u21d3"));
            th.appendChild(small);
          var big = document.createElement('big');
              big.title = this.VKI_i18n['11'];
            VKI_addListener(big, 'click', function() {
              ++self.VKI_size;
              self.VKI_kbsize();
            }, false);
            VKI_mouseEvents(big);
              big.appendChild(document.createTextNode(this.VKI_isIElt8 ? "\u2191" : "\u21d1"));
            th.appendChild(big);
        }

        var span = document.createElement('span');
            span.appendChild(document.createTextNode(this.VKI_i18n['07']));
            span.title = this.VKI_i18n['08'];
          VKI_addListener(span, 'click', function() {
            self.VKI_target.value = "";
            self.VKI_target.focus();
            return false;
          }, false);
          VKI_mouseEvents(span);
          th.appendChild(span);

        var strong = document.createElement('strong');
            strong.appendChild(document.createTextNode('X'));
            strong.title = this.VKI_i18n['06'];
          VKI_addListener(strong, 'click', function() { self.VKI_close(); }, false);
          VKI_mouseEvents(strong);
          th.appendChild(strong);

        tr.appendChild(th);
      thead.appendChild(tr);
  this.VKI_keyboard.appendChild(thead);

  var tbody = document.createElement('tbody');
    var tr = document.createElement('tr');
      var td = document.createElement('td');
        var div = document.createElement('div');

        if (this.VKI_deadBox) {
          var label = document.createElement('label');
            var checkbox = document.createElement('input');
                checkbox.type = "checkbox";
                checkbox.title = this.VKI_i18n['03'] + ": " + ((this.VKI_deadkeysOn) ? this.VKI_i18n['04'] : this.VKI_i18n['05']);
                checkbox.defaultChecked = this.VKI_deadkeysOn;
              VKI_addListener(checkbox, 'click', function() {
                this.title = self.VKI_i18n['03'] + ": " + ((this.checked) ? self.VKI_i18n['04'] : self.VKI_i18n['05']);
                self.VKI_modify("");
                return true;
              }, false);
              label.appendChild(checkbox);
                checkbox.checked = this.VKI_deadkeysOn;
            div.appendChild(label);
          this.VKI_deadkeysOn = checkbox;
        } else this.VKI_deadkeysOn.checked = this.VKI_deadkeysOn;

        if (this.VKI_showVersion) {
          var vr = document.createElement('var');
              vr.title = this.VKI_i18n['09'] + " " + this.VKI_version;
              vr.appendChild(document.createTextNode("v" + this.VKI_version));
            div.appendChild(vr);
        } td.appendChild(div);
        tr.appendChild(td);

      var kbNumpad = document.createElement('td');
          kbNumpad.id = "keyboardInputNumpad";
        if (!this.VKI_numberPadOn) kbNumpad.style.display = "none";
        var ntable = document.createElement('table');
            ntable.cellSpacing = "0";
          var ntbody = document.createElement('tbody');
            for (var x = 0; x < this.VKI_numpad.length; x++) {
              var ntr = document.createElement('tr');
                for (var y = 0; y < this.VKI_numpad[x].length; y++) {
                  var ntd = document.createElement('td');
                    VKI_addListener(ntd, 'click', VKI_keyClick, false);
                    VKI_mouseEvents(ntd);
                      ntd.appendChild(document.createTextNode(this.VKI_numpad[x][y]));
                    ntr.appendChild(ntd);
                } ntbody.appendChild(ntr);
            } ntable.appendChild(ntbody);
          kbNumpad.appendChild(ntable);
        tr.appendChild(kbNumpad);
      tbody.appendChild(tr);
  this.VKI_keyboard.appendChild(tbody);

  if (this.VKI_isIE6) {
    this.VKI_iframe = document.createElement('iframe');
    this.VKI_iframe.style.position = "absolute";
    this.VKI_iframe.style.border = "0px none";
    this.VKI_iframe.style.filter = "mask()";
    this.VKI_iframe.style.zIndex = "999999";
    this.VKI_iframe.src = this.VKI_imageURI;
  }


  
  function VKI_keyClick() {
    var done = false, character = "\xa0";
    if (this.firstChild.nodeName.toLowerCase() != "small") {
      if ((character = this.firstChild.nodeValue) == "\xa0") return false;
    } else character = this.firstChild.getAttribute('char');
    if (self.VKI_deadkeysOn.checked && self.VKI_dead) {
      if (self.VKI_dead != character) {
        if (character != " ") {
          if (self.VKI_deadkey[self.VKI_dead][character]) {
            self.VKI_insert(self.VKI_deadkey[self.VKI_dead][character]);
            done = true;
          }
        } else {
          self.VKI_insert(self.VKI_dead);
          done = true;
        }
      } else done = true;
    } self.VKI_dead = false;

    if (!done) {
      if (self.VKI_deadkeysOn.checked && self.VKI_deadkey[character]) {
        self.VKI_dead = character;
        this.className += " dead";
        if (self.VKI_shift) self.VKI_modify("Shift");
        if (self.VKI_altgr) self.VKI_modify("AltGr");
      } else self.VKI_insert(character);
    } self.VKI_modify("");
    return false;
  }


  
  this.VKI_buildKeys = function() {
    this.VKI_shift = this.VKI_shiftlock = this.VKI_altgr = this.VKI_altgrlock = this.VKI_dead = false;
    var container = this.VKI_keyboard.tBodies[0].getElementsByTagName('div')[0];
    var tables = container.getElementsByTagName('table');
    for (var x = tables.length - 1; x >= 0; x--) container.removeChild(tables[x]);

    for (var x = 0, hasDeadKey = false, lyt; lyt = this.VKI_layout[this.VKI_kt].keys[x++];) {
      var table = document.createElement('table');
          table.cellSpacing = "0";
        if (lyt.length <= this.VKI_keyCenter) table.className = "keyboardInputCenter";
        var tbody = document.createElement('tbody');
          var tr = document.createElement('tr');
            for (var y = 0, lkey; lkey = lyt[y++];) {
              var td = document.createElement('td');
                if (this.VKI_symbol[lkey[0]]) {
                  var text = this.VKI_symbol[lkey[0]].split("\n");
                  var small = document.createElement('small');
                      small.setAttribute('char', lkey[0]);
                  for (var z = 0; z < text.length; z++) {
                    if (z) small.appendChild(document.createElement("br"));
                    small.appendChild(document.createTextNode(text[z]));
                  } td.appendChild(small);
                } else td.appendChild(document.createTextNode(lkey[0] || "\xa0"));

                var className = [];
                if (this.VKI_deadkeysOn.checked)
                  for (key in this.VKI_deadkey)
                    if (key === lkey[0]) { className.push("deadkey"); break; }
                if (lyt.length > this.VKI_keyCenter && y == lyt.length) className.push("last");
                if (lkey[0] == " " || lkey[1] == " ") className.push("space");
                  td.className = className.join(" ");

                switch (lkey[1]) {
                  case "Caps": case "Shift":
                  case "Alt": case "AltGr": case "AltLk":
                    VKI_addListener(td, 'click', (function(type) { return function() { self.VKI_modify(type); return false; }})(lkey[1]), false);
                    break;
                  case "Tab":
                    VKI_addListener(td, 'click', function() {
                      if (self.VKI_activeTab) {
                        if (self.VKI_target.form) {
                          var target = self.VKI_target, elems = target.form.elements;
                          self.VKI_close();
                          for (var z = 0, me = false, j = -1; z < elems.length; z++) {
                            if (j == -1 && elems[z].getAttribute("VKI_attached")) j = z;
                            if (me) {
                              if (self.VKI_activeTab == 1 && elems[z]) break;
                              if (elems[z].getAttribute("VKI_attached")) break;
                            } else if (elems[z] == target) me = true;
                          } if (z == elems.length) z = Math.max(j, 0);
                          if (elems[z].getAttribute("VKI_attached")) {
                            self.VKI_show(elems[z]);
                          } else elems[z].focus();
                        } else self.VKI_target.focus();
                      } else self.VKI_insert("\t");
                      return false;
                    }, false);
                    break;
                  case "Bksp":
                    VKI_addListener(td, 'click', function() {
                      self.VKI_target.focus();
                      if (self.VKI_target.setSelectionRange && !self.VKI_target.readOnly) {
                        var rng = [self.VKI_target.selectionStart, self.VKI_target.selectionEnd];
                        if (rng[0] < rng[1]) rng[0]++;
                        self.VKI_target.value = self.VKI_target.value.substr(0, rng[0] - 1) + self.VKI_target.value.substr(rng[1]);
                        self.VKI_target.setSelectionRange(rng[0] - 1, rng[0] - 1);
                      } else if (self.VKI_target.createTextRange && !self.VKI_target.readOnly) {
                        try {
                          self.VKI_target.range.select();
                        } catch(e) { self.VKI_target.range = document.selection.createRange(); }
                        if (!self.VKI_target.range.text.length) self.VKI_target.range.moveStart('character', -1);
                        self.VKI_target.range.text = "";
                      } else self.VKI_target.value = self.VKI_target.value.substr(0, self.VKI_target.value.length - 1);
                      if (self.VKI_shift) self.VKI_modify("Shift");
                      if (self.VKI_altgr) self.VKI_modify("AltGr");
                      self.VKI_target.focus();
                      return true;
                    }, false);
                    break;
                  case "Enter":
                    VKI_addListener(td, 'click', function() {
                      if (self.VKI_target.nodeName != "TEXTAREA") {
                        if (self.VKI_enterSubmit && self.VKI_target.form) {
                          for (var z = 0, subm = false; z < self.VKI_target.form.elements.length; z++)
                            if (self.VKI_target.form.elements[z].type == "submit") subm = true;
                          if (!subm) self.VKI_target.form.submit();
                        }
                        self.VKI_close();
                      } else self.VKI_insert("\n");
                      return true;
                    }, false);
                    break;
                  default:
                    VKI_addListener(td, 'click', VKI_keyClick, false);

                } VKI_mouseEvents(td);
                tr.appendChild(td);
              for (var z = 0; z < 4; z++)
                if (this.VKI_deadkey[lkey[z] = lkey[z] || ""]) hasDeadKey = true;
            } tbody.appendChild(tr);
          table.appendChild(tbody);
        container.appendChild(table);
    }
    if (this.VKI_deadBox)
      this.VKI_deadkeysOn.style.display = (hasDeadKey) ? "inline" : "none";
    if (this.VKI_isIE6) {
      this.VKI_iframe.style.width = this.VKI_keyboard.offsetWidth + "px";
      this.VKI_iframe.style.height = this.VKI_keyboard.offsetHeight + "px";
    }
  };

  this.VKI_buildKeys();
  VKI_addListener(this.VKI_keyboard, 'selectstart', function() { return false; }, false);
  this.VKI_keyboard.unselectable = "on";
  if (this.VKI_isOpera)
    VKI_addListener(this.VKI_keyboard, 'mousedown', function() { return false; }, false);


  
  this.VKI_modify = function(type) {
    switch (type) {
      case "Alt":
      case "AltGr": this.VKI_altgr = !this.VKI_altgr; break;
      case "AltLk": this.VKI_altgr = 0; this.VKI_altgrlock = !this.VKI_altgrlock; break;
      case "Caps": this.VKI_shift = 0; this.VKI_shiftlock = !this.VKI_shiftlock; break;
      case "Shift": this.VKI_shift = !this.VKI_shift; break;
    } var vchar = 0;
    if (!this.VKI_shift != !this.VKI_shiftlock) vchar += 1;
    if (!this.VKI_altgr != !this.VKI_altgrlock) vchar += 2;

    var tables = this.VKI_keyboard.tBodies[0].getElementsByTagName('div')[0].getElementsByTagName('table');
    for (var x = 0; x < tables.length; x++) {
      var tds = tables[x].getElementsByTagName('td');
      for (var y = 0; y < tds.length; y++) {
        var className = [], lkey = this.VKI_layout[this.VKI_kt].keys[x][y];

        switch (lkey[1]) {
          case "Alt":
          case "AltGr":
            if (this.VKI_altgr) className.push("pressed");
            break;
          case "AltLk":
            if (this.VKI_altgrlock) className.push("pressed");
            break;
          case "Shift":
            if (this.VKI_shift) className.push("pressed");
            break;
          case "Caps":
            if (this.VKI_shiftlock) className.push("pressed");
            break;
          case "Tab": case "Enter": case "Bksp": break;
          default:
            if (type) {
              tds[y].removeChild(tds[y].firstChild);
              if (this.VKI_symbol[lkey[vchar]]) {
                var text = this.VKI_symbol[lkey[vchar]].split("\n");
                var small = document.createElement('small');
                    small.setAttribute('char', lkey[vchar]);
                for (var z = 0; z < text.length; z++) {
                  if (z) small.appendChild(document.createElement("br"));
                  small.appendChild(document.createTextNode(text[z]));
                } tds[y].appendChild(small);
              } else tds[y].appendChild(document.createTextNode(lkey[vchar] || "\xa0"));
            }
            if (this.VKI_deadkeysOn.checked) {
              var character = tds[y].firstChild.nodeValue || tds[y].firstChild.className;
              if (this.VKI_dead) {
                if (character == this.VKI_dead) className.push("pressed");
                if (this.VKI_deadkey[this.VKI_dead][character]) className.push("target");
              }
              if (this.VKI_deadkey[character]) className.push("deadkey");
            }
        }

        if (y == tds.length - 1 && tds.length > this.VKI_keyCenter) className.push("last");
        if (lkey[0] == " " || lkey[1] == " ") className.push("space");
        tds[y].className = className.join(" ");
      }
    }
  };


  
  this.VKI_insert = function(text) {
    this.VKI_target.focus();
    if (this.VKI_target.maxLength) this.VKI_target.maxlength = this.VKI_target.maxLength;
    if (typeof this.VKI_target.maxlength == "undefined" ||
        this.VKI_target.maxlength < 0 ||
        this.VKI_target.value.length < this.VKI_target.maxlength) {
      if (this.VKI_target.setSelectionRange && !this.VKI_target.readOnly && !this.VKI_isIE) {
        var rng = [this.VKI_target.selectionStart, this.VKI_target.selectionEnd];
        this.VKI_target.value = this.VKI_target.value.substr(0, rng[0]) + text + this.VKI_target.value.substr(rng[1]);
        if (text == "\n" && this.VKI_isOpera) rng[0]++;
        this.VKI_target.setSelectionRange(rng[0] + text.length, rng[0] + text.length);
      } else if (this.VKI_target.createTextRange && !this.VKI_target.readOnly) {
        try {
          this.VKI_target.range.select();
        } catch(e) { this.VKI_target.range = document.selection.createRange(); }
        this.VKI_target.range.text = text;
        this.VKI_target.range.collapse(true);
        this.VKI_target.range.select();
      } else this.VKI_target.value += text;
      if (this.VKI_shift) this.VKI_modify("Shift");
      if (this.VKI_altgr) this.VKI_modify("AltGr");
      this.VKI_target.focus();
    } else if (this.VKI_target.createTextRange && this.VKI_target.range)
      this.VKI_target.range.select();
  };


  
  this.VKI_show = function(elem) {
    if (!this.VKI_target) {
      this.VKI_target = elem;
      if (this.VKI_langAdapt && this.VKI_target.lang) {
        var chg = false, sub = [], lang = this.VKI_target.lang.toLowerCase().replace(/-/g, "_");
        for (var x = 0, chg = false; !chg && x < this.VKI_langCode.index.length; x++)
          if (lang.indexOf(this.VKI_langCode.index[x]) == 0)
            chg = kbSelect.firstChild.nodeValue = this.VKI_kt = this.VKI_langCode[this.VKI_langCode.index[x]];
        if (chg) this.VKI_buildKeys();
      }
      if (this.VKI_isIE) {
        if (!this.VKI_target.range) {
          this.VKI_target.range = this.VKI_target.createTextRange();
          this.VKI_target.range.moveStart('character', this.VKI_target.value.length);
        } this.VKI_target.range.select();
      }
      try { this.VKI_keyboard.parentNode.removeChild(this.VKI_keyboard); } catch (e) {}
      if (this.VKI_clearPasswords && this.VKI_target.type == "password") this.VKI_target.value = "";

      var elem = this.VKI_target;
      this.VKI_target.keyboardPosition = "absolute";
      do {
        if (VKI_getStyle(elem, "position") == "fixed") {
          this.VKI_target.keyboardPosition = "fixed";
          break;
        }
      } while (elem = elem.offsetParent);

      if (this.VKI_isIE6) document.body.appendChild(this.VKI_iframe);
      document.body.appendChild(this.VKI_keyboard);
      this.VKI_keyboard.style.position = this.VKI_target.keyboardPosition;
      if (this.VKI_isOpera) this.VKI_keyboard.reflow();

      this.VKI_position(true);
      if (self.VKI_isMoz || self.VKI_isWebKit) this.VKI_position(true);
      this.VKI_target.blur();
      this.VKI_target.focus();
    } else this.VKI_close();
  };


  
  this.VKI_position = function(force) {
    if (self.VKI_target) {
      var kPos = VKI_findPos(self.VKI_keyboard), wDim = VKI_innerDimensions(), sDis = VKI_scrollDist();
      var place = false, fudge = self.VKI_target.offsetHeight + 3;
      if (force !== true) {
        if (kPos[1] + self.VKI_keyboard.offsetHeight - sDis[1] - wDim[1] > 0) {
          place = true;
          fudge = -self.VKI_keyboard.offsetHeight - 3;
        } else if (kPos[1] - sDis[1] < 0) place = true;
      }
      if (place || force === true) {
        var iPos = VKI_findPos(self.VKI_target), scr = self.VKI_target;
        while (scr = scr.parentNode) {
          if (scr == document.body) break;
          if (scr.scrollHeight > scr.offsetHeight || scr.scrollWidth > scr.offsetWidth) {
            if (!scr.getAttribute("VKI_scrollListener")) {
              scr.setAttribute("VKI_scrollListener", true);
              VKI_addListener(scr, 'scroll', function() { self.VKI_position(true); }, false);
            } // Check if the input is in view
            var pPos = VKI_findPos(scr), oTop = iPos[1] - pPos[1], oLeft = iPos[0] - pPos[0];
            var top = oTop + self.VKI_target.offsetHeight;
            var left = oLeft + self.VKI_target.offsetWidth;
            var bottom = scr.offsetHeight - oTop - self.VKI_target.offsetHeight;
            var right = scr.offsetWidth - oLeft - self.VKI_target.offsetWidth;
            self.VKI_keyboard.style.display = (top < 0 || left < 0 || bottom < 0 || right < 0) ? "none" : "";
            if (self.VKI_isIE6) self.VKI_iframe.style.display = (top < 0 || left < 0 || bottom < 0 || right < 0) ? "none" : "";
          }
        }
        self.VKI_keyboard.style.top = iPos[1] - ((self.VKI_target.keyboardPosition == "fixed" && !self.VKI_isIE && !self.VKI_isMoz) ? sDis[1] : 0) + fudge + "px";
        self.VKI_keyboard.style.left = Math.max(10, Math.min(wDim[0] - self.VKI_keyboard.offsetWidth - 25, iPos[0])) + "px";
        if (self.VKI_isIE6) {
          self.VKI_iframe.style.width = self.VKI_keyboard.offsetWidth + "px";
          self.VKI_iframe.style.height = self.VKI_keyboard.offsetHeight + "px";
          self.VKI_iframe.style.top = self.VKI_keyboard.style.top;
          self.VKI_iframe.style.left = self.VKI_keyboard.style.left;
        }
      }
      if (force === true) self.VKI_position();
    }
  };


  
  this.VKI_close = VKI_close = function() {
    if (this.VKI_target) {
      try {
        this.VKI_keyboard.parentNode.removeChild(this.VKI_keyboard);
        if (this.VKI_isIE6) this.VKI_iframe.parentNode.removeChild(this.VKI_iframe);
      } catch (e) {}
      if (this.VKI_kt != this.VKI_kts) {
        kbSelect.firstChild.nodeValue = this.VKI_kt = this.VKI_kts;
        this.VKI_buildKeys();
      } kbSelect.getElementsByTagName('ol')[0].style.display = "";;
      this.VKI_target.focus();
      if (this.VKI_isIE) {
        setTimeout(function() { self.VKI_target = false; }, 0);
      } else this.VKI_target = false;
    }
  };


  
  function VKI_addListener(elem, type, func, cap) {
    if (elem.addEventListener) {
      elem.addEventListener(type, function(e) { func.call(elem, e); }, cap);
    } else if (elem.attachEvent)
      elem.attachEvent('on' + type, function() { func.call(elem); });
  }

  function VKI_findPos(obj) {
    var curleft = curtop = 0, scr = obj;
    while ((scr = scr.parentNode) && scr != document.body) {
      curleft -= scr.scrollLeft || 0;
      curtop -= scr.scrollTop || 0;
    }
    do {
      curleft += obj.offsetLeft;
      curtop += obj.offsetTop;
    } while (obj = obj.offsetParent);
    return [curleft, curtop];
  }

  function VKI_innerDimensions() {
    if (self.innerHeight) {
      return [self.innerWidth, self.innerHeight];
    } else if (document.documentElement && document.documentElement.clientHeight) {
      return [document.documentElement.clientWidth, document.documentElement.clientHeight];
    } else if (document.body)
      return [document.body.clientWidth, document.body.clientHeight];
    return [0, 0];
  }

  function VKI_scrollDist() {
    var html = document.getElementsByTagName('html')[0];
    if (html.scrollTop && document.documentElement.scrollTop) {
      return [html.scrollLeft, html.scrollTop];
    } else if (html.scrollTop || document.documentElement.scrollTop) {
      return [html.scrollLeft + document.documentElement.scrollLeft, html.scrollTop + document.documentElement.scrollTop];
    } else if (document.body.scrollTop)
      return [document.body.scrollLeft, document.body.scrollTop];
    return [0, 0];
  }

  function VKI_getStyle(obj, styleProp) {
    if (obj.currentStyle) {
      var y = obj.currentStyle[styleProp];
    } else if (window.getComputedStyle)
      var y = window.getComputedStyle(obj, null)[styleProp];
    return y;
  }


  VKI_addListener(window, 'resize', this.VKI_position, false);
  VKI_addListener(window, 'scroll', this.VKI_position, false);
  this.VKI_kbsize();
  VKI_addListener(window, 'load', VKI_buildKeyboardInputs, false);
  // VKI_addListener(window, 'load', function() {
  //   setTimeout(VKI_buildKeyboardInputs, 5);
  // }, false);
})();

document.createElement('tr8n');
document.createElement('tml');

var Tr8n = {

  // current version
  version: '1.0.0',
  host: '',
  logging: true,
  app_id: null,
  status: null, // unknown, authorized or unauthorized
  cookies: false,
  access_token: null,
  google_api_key: null,
  locale: null,
  inline_translations_enabled: false,

  url: {
    api       : '/tr8n/api/v1',
    status    : '/oauth/status',
    connect   : '/oauth/authorize',
    disconnect: '/oauth/deauthorize',
    logout    : '/oauth/logout'
  },

  UI: {

  },

  SDK: {
    TML: {},
    Tokens: {},
    Rules: {}
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Initialize the Tr8n SDK library
  // The best place to put this code is right before the closing </body> tag
  //      
  //   Tr8n.init({
  //     app_id       : 'YOUR APP KEY',             // app id or app key
  //     cookies      : true,                       // enable cookies to allow the server to access the session
  //     logging      : true                        // enable log messages to help in debugging
  //   });
  //
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  init: function(opts, cb) {
    opts || (opts = {});
    this.app_id     = opts.app_id;
    this.logging    = (window.location.toString().indexOf('debug=1') > 0)  || opts.logging || this.logging;
    this.cookies    = opts.cookies  || this.cookies;
    this.host       = opts.host     || this.host;

    Tr8n.log("Initializing Dispatcher...");

    if (window.addEventListener) {  // all browsers except IE before version 9
      window.addEventListener("message", Tr8n.onMessage, false);
    } else {
      if (window.attachEvent) {   // IE before version 9
          window.attachEvent("onmessage", Tr8n.onMessage);
      }
    }

    Tr8n.UI.Translator.init();

    Tr8n.Utils.addEvent(document, "keyup", function(event) {
      if (event.keyCode == 27) { // Capture Esc key
        Tr8n.UI.Translator.hide();
        Tr8n.UI.LanguageSelector.hide();
        Tr8n.UI.Lightbox.hide();
      }
    });

    return this;
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Cross-domain communication functions
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  postMessage: function(msg, origin) {
    var local_domain = document.location.href.split("/")[2];
    var origin_domain = origin.split("/")[2];

    if (local_domain == origin_domain) {
      window.parent.Tr8n.onMessage(msg);
    } else {
      if (parent.postMessage) {
        parent.postMessage(msg, origin);
      } else {
        alert("Failed to deliver a tr8n message: " + msg + " to origin: " + origin);
      }       
    }
  },

  onMessage:function(event) {
    var msg = '';
    if (typeof event == 'string') {
      msg = event;
    } else {
      msg = event.data;
    }

    var elements = msg.split(':');
    // if this is not a tr8n message, ignore it
    if (elements[0] != 'tr8n') return;

    if (elements[1] == 'reload') {
      window.location.reload();
      return;
    }

    if (elements[1] == 'cookie') {
      document.cookie = escape(elements[2]) + "=" + escape(elements[3]) + "; path=/";
      return;
    }

    if (elements[1] == 'translation') {
      if (elements[2] == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?translation_id=' + elements[3], {width:600, height:360});
        return;
      } 
    }

    if (elements[1] == 'language_selector') {
      if (elements[2] == 'change') { Tr8n.UI.LanguageSelector.change(elements[3]); return; } 
      if (elements[2] == 'toggle_inline_translations') { Tr8n.UI.LanguageSelector.toggleInlineTranslations(); return; } 
    }

    if (elements[1] == 'language_case_map') {
      if (elements[2] == 'report') {
        Tr8n.UI.Translator.hide();
        Tr8n.UI.Lightbox.show('/tr8n/translator/lb_report?language_case_map_id=' + elements[3], {width:600, height:360});
        return;
      } 
    }

    if (elements[1] == 'lightbox') {
      if (elements[2] == 'resize') { Tr8n.UI.Lightbox.resize(elements[3]); return; } 
      if (elements[2] == 'hide') { Tr8n.UI.Lightbox.hide(); return;}
    }

    if (elements[1] == 'translator') {
      if (elements[2] == 'resize') { Tr8n.UI.Translator.resize(elements[3]); return; } 
      if (elements[2] == 'hide') { Tr8n.UI.Translator.hide(); return; }
    } 

    alert("Unknown message: " + msg);
  }

};


Tr8n.Logger = {

  console_element_id: 'tr8n_console',
  object_keys: {},

  clear: function() {
    if (!Tr8n.element(Tr8n.Logger.console_element_id)) return;
    Tr8n.element(Tr8n.Logger.console_element_id).innerHTML = ""; 
  },

  append: function(msg) {
    if (!Tr8n.element(Tr8n.Logger.console_element_id)) return;
    Tr8n.element(Tr8n.Logger.console_element_id).innerHTML = msg + "<br>" + Tr8n.element(Tr8n.Logger.console_element_id).innerHTML; 
  },

  timestampMessage: function(msg) {
    var now = new Date();
    return "<span style='color:#ccc;'>" + (now.toLocaleDateString() + " " + now.toLocaleTimeString()) + "</span>: " + msg;
  },

  log: function(msg) {
    if (!Tr8n.logging) return;

    if (window.console) window.console.log("tr8n: " + msg);

    Tr8n.Logger.append(Tr8n.Logger.timestampMessage(msg)); 
  },

  debug: function(msg) {
    if (!Tr8n.logging) return;

    if (window.console) window.console.debug(msg);

    Tr8n.Logger.append(Tr8n.Logger.timestampMessage("<span style='color:grey'>" + msg + "</span>")); 
  },

  error: function(msg) {
    if (!Tr8n.logging) return;

    if (window.console) window.console.error(msg);

    Tr8n.Logger.append(Tr8n.Logger.timestampMessage("<span style='color:red'>" + msg + "</span>")); 
  },

  S4: function() {
    return (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },

  guid: function() {
    return (Tr8n.Logger.S4()+Tr8n.Logger.S4()+"-"+Tr8n.Logger.S4()+"-"+Tr8n.Logger.S4()+"-"+Tr8n.Logger.S4()+"-"+Tr8n.Logger.S4()+Tr8n.Logger.S4()+Tr8n.Logger.S4());
  },

  escapeHTML: function(str) { 
    return( str.replace(/&/g,'&amp;').replace(/>/g,'&gt;').replace(/</g,'&lt;').replace(/"/g,'&quot;')); 
  },

  showObject: function (obj_key, flag) {
    if (flag) {
      Tr8n.Effects.hide("no_object_" + obj_key);
      Tr8n.Effects.show("object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='" + Tr8n.host + "/assets/tr8n/minus_node.png'>";
    } else {
      Tr8n.Effects.hide("object_" + obj_key);
      Tr8n.Effects.show("no_object_" + obj_key);
      Tr8n.element("expander_" + obj_key).innerHTML = "<img src='" + Tr8n.host + "/assets/tr8n/plus_node.png'>";
    } 
  },

  toggleNode: function(obj_key) {
    Tr8n.Logger.showObject(obj_key, (Tr8n.element("object_" + obj_key).style.display == 'none'));
  },

  expandAllNodes: function() {
    for (var i=0; i<Tr8n.Logger.object_keys.length; i++) {
      this.showObject(Tr8n.Logger.object_keys[i], true);
    }
  },

  collapseAllNodes: function() {
    for (var i=0; i<this.object_keys.length; i++) {
      this.showObject(this.object_keys[i], false);
    }
  },

  logObject: function(obj) {
    this.append(this.objectToHtml(obj));
  },

  objectToHtml: function(data) {
    this.object_keys = [];
    html = []
    html.push("<div style='float:right;padding-right:10px;'>");
    html.push("<span style='padding:2px;' onClick=\"Tr8n.Logger.expandAllNodes()\"><img src='" + Tr8n.host + "/assets/tr8n/plus_node.png'></span>");
    html.push("<span style='padding:2px;' onClick=\"Tr8n.Logger.collapseAllNodes()\"><img src='" + Tr8n.host + "/assets/tr8n/minus_node.png'></span>");
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

    return html.join("\n");
  },

  formatObject: function(obj, level) {
    if (obj == null) return "{<br>}";

    var html = [];
    var obj_key = this.guid();  
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"Tr8n.Logger.toggleNode('" + obj_key + "')\"><img src='" + Tr8n.host + "/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>{...}</span> <span id='object_" + obj_key + "'>{");
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
    html.push("<span class='tr8n_logger_expander' id='expander_" + obj_key + "' onClick=\"Tr8n.Logger.toggleNode('" + obj_key + "')\"><img src='" + Tr8n.host + "/assets/tr8n/minus_node.png'></span> <span style='display:none' id='no_object_" + obj_key + "'>[...]</span> <span id='object_" + obj_key + "'>[");
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
    return "<img src='" + Tr8n.host + "/assets/tr8n/pixel.gif' style='height:1px;width:" + (level * 20) + "px;'>";
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


Tr8n.Cookie = function (key, value, options) {
	if (!Tr8n.cookies) return;

  if (arguments.length > 1 && String(value) !== "[object Object]") {
		options = Tr8n.Utils.extend({}, options);

		if (value === null || value === undefined) options.expires = -1;

		if (typeof options.expires === 'number') {
			var days = options.expires, t = options.expires = new Date();
			t.setDate(t.getDate() + days);
		}

		value = String(value);
		return (document.cookie = [
			encodeURIComponent(key), '=',
			options.raw 		? value : encodeURIComponent(value),
			options.expires ? '; expires=' + options.expires.toUTCString() : '',
			options.path 		? '; path=' + options.path : '',
			options.domain 	? '; domain=' + options.domain : '',
			options.secure 	? '; secure' : ''
		].join(''));
  }
  
  options = value || {};
  var result, decode = options.raw ? function (s) { return s; } : decodeURIComponent;
  return (result = new RegExp('(?:^|; )' + encodeURIComponent(key) + '=([^;]*)').exec(document.cookie)) ? decode(result[1]) : null;
}


Tr8n.Event = {

  events: {},

  /////////////////////////////////////////////////////////////////////////////////////
  // Bind an event, specified by a string name, 'event', to a callback, 'cb', function.
  /////////////////////////////////////////////////////////////////////////////////////

  bind: function(event, cb) {
  	this.events[event] = this.events[event]	|| [];
  	this.events[event].push(cb);
  },

  /////////////////////////////////////////////////////////////////////////////////////
  // Remove one or many callbacks. If callback is null, all
  // callbacks for the event wil be removed.
  /////////////////////////////////////////////////////////////////////////////////////

  unbind: function(event, cb) {
  	if(event in this.events === false)	return;
  	this.events[event].splice(this.events[event].indexOf(cb), 1);
  	if(!cb) delete this.events[event];
  },

  /////////////////////////////////////////////////////////////////////////////////////
  // Trigger an event, firing all bound callbacks. Callbacks are passed the
  // same arguments as 'trigger' is, apart from the event name.
  /////////////////////////////////////////////////////////////////////////////////////

  trigger: function(event) {
  	if( event in this.events === false  )	return;
  	for(var i = 0; i < this.events[event].length; i++){
  		this.events[event][i].apply(this, Array.prototype.slice.call(arguments, 1))
  	}
  }

}


Tr8n.Utils = {

  element: function(element_id) {
    if (typeof element_id == 'string') return document.getElementById(element_id);
    return element_id;
  },

  value: function(element_id) {
    return Tr8n.element(element_id).value;
  },

  extend: function(destination, source) {
    for (var property in source) 
      destination[property] = source[property];
    return destination;
  },

  hideFlash: function() {
    // alert("Hiding");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'hidden';
    } 
  },

  showFlash: function() {
    // alert("Showing");
    var embeds = document.getElementsByTagName('embed');
    for(i = 0; i < embeds.length; i++) {
        embeds[i].style.visibility = 'visible';
    } 
  },

  isOpera: function() {
    return /Opera/.test(navigator.userAgent);
  },

  uuid: function() {
    return 'tr8n' + (((1+Math.random())*0x10000)|0).toString(16).substring(1);
  },

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

  // Create a URL-encoded query string from an object
  encodeQueryString: function(obj,prefix) {
    var str = [];
    for(var p in obj) str.push(encodeURIComponent(p) + "=" + encodeURIComponent(obj[p]));
    return str.join("&");
  },

  // Parses a query string and returns an object composed of key/value pairs
  decodeQueryString: function(qs) {
    var
      obj = {},
      segments = qs.split('&'),
      kv;
    for (var i=0; i<segments.length; i++) {
      kv = segments[i].split('=', 2);
      if (kv && kv[0]) {
        obj[decodeURIComponent(kv[0])] = decodeURIComponent(kv[1]);
      }
    }
    return obj;
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

  toUrl: function(url, params) {
    params = params || {};
    params['origin'] = window.location;
    url = Tr8n.host + url + (url.indexOf('?') == -1 ? '?' : '&') + Tr8n.Utils.toQueryParams(params);
    return url
  },

  serializeForm: function(form) {
    var els = Tr8n.element(form).elements;
    var form_obj = {}
    for(i=0; i < els.length; i++) {
      if (els[i].type == 'checkbox' && !els[i].checked) continue;
      form_obj[els[i].name] = els[i].value;
    }
    return form_obj;
  },

  indexOf: function(array, item, i) {
    i || (i = 0);
    var length = array.length;
    if (i < 0) i = length + i;
    for (; i < length; i++)
      if (array[i] === item) return i;
    return -1;
  },

  replaceAll: function(label, key, value) {
    while (label.indexOf(key) != -1) {
      label = label.replace(key, value);
    }
    return label;
  },

  trim: function(string) {
    return string.replace(/^\s+|\s+$/g,"");
  },

  ltrim: function(string) {
    return string.replace(/^\s+/,"");
  },

  rtrim: function(string) {
    return string.replace(/\s+$/,"");
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

  getMetaAttributes: function() {
    var meta_hash = {};
    var meta = document.getElementsByTagName("meta");
    for (var i=0; i<meta.length; i++) {
      var name = meta[i].getAttribute('name'); 
      var content = meta[i].getAttribute('content'); 
      if (!name || !content) continue;
      meta_hash[name] = content;
    }
    return meta_hash;
  },

  ajax: function(url, options) {
    options = options || {};
    options.parameters = options.parameters || {};

    var meta = Tr8n.Utils.getMetaAttributes();
    if (meta['csrf-param'] && meta['csrf-token']) {
      options.parameters[meta['csrf-param']] = meta['csrf-token'];
    }
    options.parameters = Tr8n.Utils.toQueryParams(options.parameters);
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
    request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  update: function(element_id, url, options) {
    options.onSuccess = function(response) {
        Tr8n.element(element_id).innerHTML = response.responseText;
    };
    Tr8n.Utils.ajax(url, options);
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

  hasClassName:function(el, cls){
    var exp = new RegExp("(^|\\s)"+cls+"($|\\s)");
    return (el.className && exp.test(el.className))?true:false;
  },

  findElement: function (e, selector, el) {
    var event = e || window.event;
    var target = el || event.target || event.srcElement;
    if (target == null || target == document.body || target.tagName == 'HTML') return null;
    var condition = (selector.match(/^\./)) ? this.hasClassName(target,selector.replace(/^\./,'')) : (target.tagName.toLowerCase() == selector.toLowerCase());
    if (condition) {
      return target;
    } else {
      return this.findElement(e, selector, target.parentNode);
    }
  },

  // deprecated
  cumulativeOffset: function(element) {
    var valueT = 0, valueL = 0;
    do {
      valueT += element.offsetTop  || 0;
      valueL += element.offsetLeft || 0;
      element = element.offsetParent;
    } while (element);
    return [valueL, valueT];
  },

  elementRect: function(element) {
    var valueT = 0, valueL = 0, el = element;
    do {
      valueT += el.offsetTop  || 0;
      valueL += el.offsetLeft || 0;
      el = el.offsetParent;
    } while (el);
    return {left: valueL, top: valueT, width: element.offsetWidth, height: element.offsetHeight};
  },

  wrapText: function (obj_id, beginTag, endTag) {
    var obj = document.getElementById(obj_id);

    if (typeof obj.selectionStart == 'number') {
        // Mozilla, Opera, and other browsers
        var start = obj.selectionStart;
        var end   = obj.selectionEnd;
        obj.value = obj.value.substring(0, start) + beginTag + obj.value.substring(start, end) + endTag + obj.value.substring(end, obj.value.length);

    } else if(document.selection) {
        // Internet Explorer
        obj.focus();
        var range = document.selection.createRange();
        if(range.parentElement() != obj)
          return false;

        if(typeof range.text == 'string')
          document.selection.createRange().text = beginTag + range.text + endTag;
    } else
        obj.value += beginTag + " " + endTag;

    return true;
  },

  insertAtCaret: function (areaId, text) {
    var txtarea = document.getElementById(areaId);
    var scrollPos = txtarea.scrollTop;
    var strPos = 0;
    var br = ((txtarea.selectionStart || txtarea.selectionStart == '0') ? "ff" : (document.selection ? "ie" : false ) );

    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      strPos = range.text.length;
    } else if (br == "ff")
      strPos = txtarea.selectionStart;

    var front = (txtarea.value).substring(0, strPos);
    var back = (txtarea.value).substring(strPos, txtarea.value.length);
    txtarea.value=front+text+back;

    strPos = strPos + text.length;
    if (br == "ie") {
      txtarea.focus();
      var range = document.selection.createRange();
      range.moveStart ('character', -txtarea.value.length);
      range.moveStart ('character', strPos);
      range.moveEnd ('character', 0); range.select();
    }  else if (br == "ff") {
      txtarea.selectionStart = strPos;
      txtarea.selectionEnd = strPos;
      txtarea.focus();
    }
    txtarea.scrollTop = scrollPos;
  },

  toggleKeyboards: function() {
    if(!VKI_attach) return;
    if (!this.keyboardMode) {
      Tr8n.UI.Lightbox.showHTML("<div style='text-align:center;font-size:15px;'>Software keyboard has been enabled.</div>", {width:400, height:50});

      this.keyboardMode = true;

      var elements = document.getElementsByTagName("input");
      for(i=0; i<elements.length; i++) {
        if (elements[i].type == "text") VKI_attach(elements[i]);
      }
      elements = document.getElementsByTagName("textarea");
      for(i=0; i<elements.length; i++) {
        VKI_attach(elements[i]);
      }
      window.setTimeout(function() {
        Tr8n.UI.Lightbox.hide();
      }, 2000);    
    } else {
      Tr8n.UI.Lightbox.showHTML("<div style='text-align:center;font-size:15px;'>Software keyboard has been disabled.</div>", {width:400, height:50});
      window.setTimeout(function() {
        window.location.reload();
      }, 1000);    
    }
  },

  insertCSS: function(cssHref, parent_element) {
    var css = document.createElement('link');
    css.setAttribute("type", "application/javascript");
    css.setAttribute("href", cssHref);
    css.setAttribute("type", "text/css");
    css.setAttribute("rel", "stylesheet");
    css.setAttribute("media", "screen");
    parent_element = parent_element || document.getElementsByTagName('head')[0];
    parent_element.appendChild(css);
  },

  insertScript: function(scriptURL, onload, parent_element) {
    parent_element = parent_element || document;
    var script = document.createElement('script');
    script.setAttribute("type", "application/javascript");
    script.setAttribute("src", scriptURL);
    script.setAttribute("charset", "UTF-8");
    if (onload) script.onload = onload;
    parent_element = parent_element || document.getElementsByTagName('head')[0];
    parent_element.appendChild(script);
  },

  insertDiv: function(id, style, innerHTML) {
    var div = document.createElement('div');
    div.id = id;
    if (style) div.setAttribute("style", style);
    if (innerHTML) div.innerHTML = innerHTML;
    document.body.appendChild(div);
  },

  sanitizeString: function(string) {
    if (!string) return "";   
    return string.replace(/^\s+|\s+$/g,"");
  },

  isNumber: function(str) {
    return str.search(/^\s*\d+\s*$/) != -1;
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


Tr8n.Effects = {
  toggle: function(element_id) {
    if (Tr8n.element(element_id).style.display == "none")
      Tr8n.element(element_id).show();
    else
      Tr8n.element(element_id).hide();
  },
  hide: function(element_id) {
    Tr8n.element(element_id).style.display = "none";
  },
  show: function(element_id) {
    var style = (Tr8n.element(element_id).tagName == "SPAN") ? "inline" : "block";
    Tr8n.element(element_id).style.display = style;
  },
  blindUp: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  blindDown: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  appear: function(element_id) {
    Tr8n.Effects.show(element_id);
  },
  fade: function(element_id) {
    Tr8n.Effects.hide(element_id);
  },
  submit: function(element_id) {
    Tr8n.element(element_id).submit();
  },
  focus: function(element_id) {
    Tr8n.element(element_id).focus();
  },
  animateHeight: function(element_id, height) {
   var obj = Tr8n.element(element_id);
   var obj_height = obj.clientHeight;
   if(obj_height >= height) return;

   obj.style.height = (obj_height + 20) + "px";
   setTimeout(function() {
       Tr8n.Effects.animateHeight(obj, height);
   }, 10); 
  },
  scrollTo: function(element_id) {
    var theElement = Tr8n.element(element_id);
    var selectedPosX = 0;
    var selectedPosY = 0;
    while(theElement != null){
      selectedPosX += theElement.offsetLeft;
      selectedPosY += theElement.offsetTop;
      theElement = theElement.offsetParent;
    }
    window.scrollTo(selectedPosX,selectedPosY);
  }
}

Tr8n.SDK.Request = {

	callbacks : {},
	
  evalResults: function(str) {
    return eval("[" + str + "]")[0];
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // Standard AJAX request
  //
  //    Tr8n.SDK.Request.ajax(url[, options])
  //
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  ajax: function(url, options) {
    options = options || {};
    options.parameters = options.parameters || {};

    var meta = Tr8n.Utils.getMetaAttributes();
    if (meta['csrf-param'] && meta['csrf-token']) {
      options.parameters[meta['csrf-param']] = meta['csrf-token'];
    }
    options.parameters = Tr8n.Utils.toQueryParams(options.parameters);
    options.method = options.method || 'get';

    var self=this;
    if (options.method == 'get' && options.parameters != '') {
      url = url + (url.indexOf('?') == -1 ? '?' : '&') + options.parameters;
    }

    var request = Tr8n.Utils.getRequest();

    request.onreadystatechange = function() {
      if(request.readyState == 4) {
        if (request.status == 200) {
          if (options.onSuccess) options.onSuccess(self.evalResults(request.responseText));
          if (options.onComplete) options.onComplete(self.evalResults(request.responseText));
          if (options.evalScripts) Tr8n.Utils.evalScripts(request.responseText);
        } else {
          if (options.onFailure) options.onFailure(request)
          if (options.onComplete) options.onComplete(request)
        }
      }
    }

    request.open(options.method, url, true);
    request.setRequestHeader('X-Requested-With', 'XMLHttpRequest');
    request.setRequestHeader('Content-type', 'application/x-www-form-urlencoded');
    request.setRequestHeader('Accept', 'text/javascript, text/html, application/xml, text/xml, */*');
    request.send(options.parameters);
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Standard JSONP request
	//
	// 		Tr8n.SDK.Request.jsonp(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	jsonp: function(url, params, cb) {
		var 
			self    = this,
			script 	= document.createElement('script'),
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}), {callback: 'Tr8n.SDK.Request.callbacks.' + uuid}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);

		this.callbacks[uuid] = function(data) {
			if(data.error) {
				Tr8n.log([data.error,data.error_description].join(' : '));
			}
			if(cb) cb(data);
			delete self.callbacks[uuid];
		}
		script.src = url;
		document.getElementsByTagName('head')[0].appendChild(script);
	},
	
  ///////////////////////////////////////////////////////////////////////////////////////////////  
  // CORS request
  //
  //    Tr8n.SDK.Request.cors(url[, paramerters, callback])
  //
  ///////////////////////////////////////////////////////////////////////////////////////////////  

  cors: function(url, params, cb) {
    window.tr8nJQ.ajax({
        url: url,
        type: 'POST',
        data: params,
        crossDomain: true
    })
    .done(function(data) { 
      if(cb) cb(window.tr8nJQ.parseJSON(data));
    })
    .fail(function(data) {
      alert("error"); 
    })
    .always(function(data) {

    });    
  },

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Same as a jsonp request but with an access token for oauth authentication
	//
	// 		Tr8n.SDK.Request.oauth(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	oauth: function(url, params, cb) {
		params || (params = {});
		if (Tr8n.access_token) {
			Tr8n.Utils.extend(params, {access_token: Tr8n.access_token});
		} 
		
		this.cors(url, params, cb);
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Opens a popup window with the given url and places it at the
	// center of the current window. Used for app authentication. Should only 
	// be called on a user event like a click as many browsers block popups 
	// if not initiated by a user. 
	//
	// 		Tr8n.Request.popup(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	popup: function(url, params, cb) {
		this.registerXDHandler();
		// figure out where the center is
		var
			screenX    	= typeof window.screenX != 'undefined' ? window.screenX : window.screenLeft,
			screenY    	= typeof window.screenY != 'undefined' ? window.screenY : window.screenTop,
			outerWidth 	= typeof window.outerWidth != 'undefined' ? window.outerWidth : document.documentElement.clientWidth,
			outerHeight = typeof window.outerHeight != 'undefined' ? window.outerHeight : (document.documentElement.clientHeight - 22),
			width    		= params.width 	|| 600,
			height   		= params.height || 400,
			left     		= parseInt(screenX + ((outerWidth - width) / 2), 10),
			top      		= parseInt(screenY + ((outerHeight - height) / 2.5), 10),
			features = (
				'width=' + width +
				',height=' + height +
				',left=' + left +
				',top=' + top
			);
		var 
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}),{
				callback	: uuid,
				display		: 'popup',
				origin		: this.origin()
			}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);
		var win = window.open(url, uuid, features);
		this.callbacks[uuid] = function(data) {
			if(cb) cb(data,win);
			delete Tr8n.SDK.Request.callbacks[uuid];
		}
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Creates and inserts a hidden iframe with the given url then removes 
	// the iframe from the DOM
	//
	// 		Tr8n.SDK.Request.hidden(url[, paramerters, callback])
	//
  ///////////////////////////////////////////////////////////////////////////////////////////////  

	hidden: function(url, params, cb) {
		this.registerXDHandler();
		var 
			iframe 	= document.createElement('iframe'),
			uuid		= Tr8n.Utils.uuid(),
			params 	= Tr8n.Utils.extend((params||{}),{
				callback	: uuid,
				display		: 'hidden',
				origin		: this.origin()
			}),
			url 		= url + (url.indexOf('?')>-1 ? '&' : '?') + Tr8n.Utils.encodeQueryString(params);
			
		iframe.style.display = "none";
		this.callbacks[uuid] = function(data) {
			if(cb) cb(data);
			delete Tr8n.SDK.Request.callbacks[uuid];
			iframe.parentNode.removeChild(iframe);
		}
		iframe.src = url;
		document.getElementsByTagName('body')[0].appendChild(iframe);
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// Make sure we're listening to the onMessage event
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	registerXDHandler: function() {
		if(this.xd_registered) return;
		var 
			self = Tr8n.SDK.Request,
			fn = function(e) { Tr8n.SDK.Request.onMessage(e) }
		
    window.addEventListener ? window.addEventListener('message', fn, false) : window.attachEvent('onmessage', fn);
		this.xd_registered = true;
	},

  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// handles message events sent via postMessage, and fires the appropriate callback
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	onMessage: function(e) {
		var data = {};
		if (e.data && typeof e.data == 'string') {
			data = Tr8n.Utils.decodeQueryString(e.data);
		}
		
		if (data.error) {
			Tr8n.log(data.error, data.error_description);
		}
		
		if (data.callback) {
			var cb = this.callbacks[data.callback];
			if (cb) {
				cb(data);
				delete this.callbacks[data.callback];
			}
		}
	},
	
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	// get the origin of the page
  ///////////////////////////////////////////////////////////////////////////////////////////////  
	origin: function() {
		return (window.location.protocol + '//' + window.location.host)
	},

  sameOrigin: function() {
    if (Tr8n.host == '') return true;
    var local_domain = document.location.href.split("/")[2];
    var origin_domain = Tr8n.host.split("/")[2];

    return (local_domain == origin_domain);
  }

}


Tr8n.SDK.Api = {

	// Makes an oauth jsonp request to Tr8n's servers for data.
	//
	// 		Tr8n.SDK.Api.get('/translator', function(data){
	//			// do something awesome with Tr8n data
	//		})
	//
	get: function(path, params, cb) {
    if (typeof params == 'function') {
      cb = params;
      params = {};
    } 

    params || (params = {});
    if (params.method) {
      params['_method'] = params.method;
      delete params.method;
    }

    params["locale"] = Tr8n.locale;
    path = Tr8n.host + Tr8n.url.api + "/" + path.replace(/^\//,'');

    if (Tr8n.SDK.Request.sameOrigin()) {
      var method = params['_method'] || 'get';
      delete params._method;

      return Tr8n.SDK.Request.ajax(path, {
        method: method,
        parameters: params,
        onSuccess: cb
      });
    }
  
    Tr8n.SDK.Request.oauth(path, params, cb);
	},	
	
	// Makes an oauth jsonp request to Tr8n's servers to save data. All jsonp
	// requests use a GET method but we can get around this by adding a 
	// _method=post parameter to our request.
	//
	// 		Tr8n.Api.post('/translator', function(data){
	//			// Add awesome data to Tr8n
	//		})
	//
	post: function(path, params, cb) {
		params = Tr8n.Utils.extend({'_method':'post'}, params || {});
		this.get(path, params, cb);
	}
		
}
	

Tr8n.SDK.Auth = {
	
	// Returns the current authentication status of the user from the server, and provides
	// an access token if the user is logged into Tr8n and has authorized the app.
	//
	// 		Tr8n.SDK.Auth.getStatus(function(response){
	//			if(response.status == 'authorized') {
	//				// User is logged in and has authorized the app
	//			}
	//		})
	//
	// The status returned in the response will be either 'authorized', user is logged in
	// and has authorized the app, 'unauthorized', user is logged in but has not authorized 
	// the app and 'unknown', user is not logged in.
	
	getStatus: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.Auth.getStatus() called without an app id');
		}
		var url = Tr8n.host + Tr8n.url.status;

		Tr8n.SDK.Request.hidden(url,{client_id:Tr8n.app_id}, function(data) {
			Tr8n.SDK.Auth.setStatus(data);
			if(cb) cb(data);
		});
	},
	
	// Launches the authorization window to connect to Tr8n and if successful returns an
	// access token.
	//
	// 		Tr8n.SDK.Auth.connect(function(response) {
	//			if(response.status == 'authorized') {
	//				// User is logged in and has authorized the app
	//			}
	//		})
	//
	
	connect: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.connect() called without an app id.');
		}

		if(!Tr8n.access_token) {
			var url = Tr8n.host + Tr8n.url.connect,
  				params = {
  					response_type	: 'token',
  					client_id			: Tr8n.app_id
  				};

			Tr8n.SDK.Request.popup(url, params, function(data, win) {
				Tr8n.SDK.Auth.setStatus(data);
				if(win) win.close();
				if(cb) cb(data);
			});
		} else {
			Tr8n.log('Tr8n.SDK.Auth.connect() called when user is already connected.');
			if(cb) cb();
		}
	},
	
	// Revokes your apps authorization access
	//
	// 		Tr8n.SDK.Auth.disconnect(function(){
	//			// App authorization has been revoked
	//		})
	//
	disconnect: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.disconnect() called without an app id.');
		}
		var url = Tr8n.host + Tr8n.url.disconnect;
		Tr8n.SDK.Request.jsonp(url, {client_id:Tr8n.app_id}, function(r) {
			Tr8n.SDK.Auth.setStatus(null);
			if(cb) cb(r);
		})
	},
	
	// Logs the user out of Tr8n
	//
	// 		Tr8n.SDK.Auth.logout(function(){
	//			// App authorization has been revoked
	//		})
	//
	logout: function(cb) {
		if(!Tr8n.app_id) {
			return Tr8n.log('Tr8n.SDK.Auth.logout called() without an app id.');
		}
		var url = Tr8n.host + Tr8n.url.logout;

		Tr8n.Request.jsonp(url, {client_id:Tr8n.app_id}, function(r) {
			Tr8n.SDK.Auth.setStatus(null);
			if(cb) cb(r);
		});
	},
	
	// Determines the correct status ('unknown', 'unauthorized' or 'authorized') and 
	// sets the access token if authorization is approved.
	setStatus: function(data) {
		data || (data = {});
		
    if (data.access_token) {
			Tr8n.access_token = data.access_token;
			Tr8n.Cookie('geni' + Tr8n.app_id, Tr8n.access_token);
			data.status = "authorized";
		} else {
			Tr8n.access_token = null;
			Tr8n.Cookie('tr8n' + Tr8n.app_id, null);
			data.status = data.status || "unknown";
		}

		if(Tr8n.status != data.status) {
			Tr8n.Event.trigger('auth:statusChange', data.status);
		}
		return (Tr8n.status = data.status);
	}

}



///////////////////////////////////////////////////////////////////////////
// Tr8n.SDK.Proxy.init({
//   "default_source": "welcome/index/JS",
//   "scheduler_interval": 5000,
//   "enable_inline_translations": true,
//   "enable_tml": true,
//   "default_decorations": {
//     "strong":"<strong>{$0}</strong>",
//     "bold":"<strong>{$0}</strong>",
//     "b":"<strong>{$0}</strong>",
//     "em":"<em>{$0}</em>",
//     "italic":"<i>{$0}</i>",
//     "i":"<i>{$0}</i>",
//     "link":"<a href='{$href}'>{$0}</a>",
//     "br":"<br>{$0}",
//     "div":"<div id='{$id}' class='{$class}' style='{$style}'>{$0}</div>",
//     "span":"<span id='{$id}' class='{$class}' style='{$style}'>{$0}</span>",
//     "h1":"<h1>{$0}</h1>",
//     "h2":"<h2>{$0}</h2>",
//     "h3":"<h3>{$0}</h3>"
//   },
//   "default_tokens": {
//     "ndash":"&ndash;",
//     "mdash":"&mdash;",
//     "iexcl":"&iexcl;",
//     "iquest":"&iquest;",
//     "quot":"&quot;",
//     "ldquo":"&ldquo;",
//     "rdquo":"&rdquo;",
//     "lsquo":"&lsquo;",
//     "rsquo":"&rsquo;",
//     "laquo":"&laquo;",
//     "raquo":"&raquo;",
//     "nbsp":"&nbsp;",
//     "lsaquo":"&lsaquo;",
//     "rsaquo":"&rsaquo;",
//     "br":"<br/>",
//     "lbrace":"{",
//     "rbrace":"}"
//   },
//   "rules": {
//     "number": {
//       "token_suffixes": ["count","num","age","hours","minutes","years","seconds"],
//       "object_method": "to_i"
//     },
//     "gender": {
//       "token_suffixes": ["user","profile","actor","target","partner"], 
//       "object_method": "gender",
//       "method_values": {
//         "female": "female",
//         "male": "male",
//         "neutral": "neutral",
//         "unknown": "unknown"
//       }
//     },
//     "list": {
//       "object_method": "size",
//       "token_suffixes": ["list"]
//     }, 
//     "date": {
//       "token_suffixes": ["date"],
//       "object_method": "to_date"
//     }
//   }
// });
///////////////////////////////////////////////////////////////////////////


Tr8n.SDK.Proxy = {

  options: {},
  scheduler_enabled: true,
  inline_translations_enabled: false,
  tml_enabled: false,
  text_enabled: false,
  scheduler_interval: 5000,
  batch_size: 5,
  language: null,
  translations: {},
  missing_translation_keys: {},

  init: function(opts) {
    Tr8n.log("Initializing Client SDK...");

    this.options = opts || (opts = {});
    this.scheduler_interval = this.options['scheduler_interval'] || this.scheduler_interval; 
    this.inline_translations_enabled = this.options['enable_inline_translations'];
    Tr8n.inline_translations_enabled = this.options['enable_inline_translations'];
    this.tml_enabled = this.options['enable_tml'];
    this.text_enabled = this.options['enable_text'];

    this.language = new Tr8n.SDK.Language();

    this.initTranslations();
    this.runScheduledTasks();

    return this;
  },

  shouldBeTranslated: function(label) {
    // blanks
    if (!label || label == "") return false;
    // one character strings
    if (label.length < 2) return false;
    // 1  12,344 23,956,669.34 - numbers should never be translated
    if (/^[\d.,]*$/.test(label)) return false;
    // non human readable text
    if (/^[~`!@#$%\^&*\(\)\{\}\[\]|:"<>?;'\.\s\\,\+\-\/]*$/.test(label)) return false;
    return true;
  },

  translate: function(label, description, tokens, options) {
    if (!this.shouldBeTranslated(label))
      return label;

    description = description || "";
    tokens = tokens || {};
    options = options || {};
    return this.language.translate(label, description, tokens, options);
  },

  tr: function(label, description, tokens, options) {
    return this.translate(label, description, tokens, options);
  },

  trl: function(label, description, tokens, options) {
    options = options || {};
    options['skip_decorations'] = true;
    return this.translate(label, description, tokens, options);
  },

  getDecorationFor: function(decoration_name) {
    if (!this.options['default_decorations'])
      return null;
    return this.options['default_decorations'][decoration_name];
  },

  getLanguageRuleForType: function(rule_type) {
    // modify this section to add more rules
    if (rule_type == 'number')        return 'Tr8n.SDK.Rules.NumericRule';
    if (rule_type == 'gender')        return 'Tr8n.SDK.Rules.GenderRule';
    if (rule_type == 'date')          return 'Tr8n.SDK.Rules.DateRule';
    if (rule_type == 'list')          return 'Tr8n.SDK.Rules.ListRule';
    if (rule_type == 'gender_list')   return 'Tr8n.SDK.Rules.GenderListRule';
    return null;    
  },

  getLanguageRuleForTokenSuffix: function(token_suffix) {
    if (!this.options['rules']) return null;
    
    for (rule_type in this.options['rules']) {
      var suffixes = this.options['rules'][rule_type]['token_suffixes'];
      if (!suffixes) continue;
      
      if (Tr8n.Utils.indexOf(suffixes, token_suffix) != -1 )
         return this.getLanguageRuleForType(rule_type);     
    }
    return null;    
  },

  registerTranslationKeys: function(translations) {
    if (!Tr8n.Utils.isArray(translations)) {
      translations = translations['phrases'];
    }

    Tr8n.log("Found " + translations.length + " registered phrases");

    for (i = 0; i < translations.length; i++) {
       var translation_key = translations[i];
       // Tr8n.log("Registering " + translation_key['key']);
       this.translations[translation_key['key']] = translation_key;
    }
  },

  initTranslations: function() {
    // Check for page variable to load translations from, if variable was provided
    if (this.options['translations_cache_id']) {
      this.log("Registering page translations from translations cache...");
      this.registerTranslationKeys(eval(this.options['translations_cache_id']));
    }

    var self = this;
    
    // Tr8n.log("Before fetching translations " + this.options['fetch_translations_on_init']);

    // Optionally, fetch translations from the server
    if (this.options['fetch_translations_on_init']) {
      Tr8n.log("Fetching translations from the server...");

      Tr8n.api('language/translate', {
        'batch': true, 
        'source': Tr8n.source
      }, function(data) {
          Tr8n.log("Received response from the server");
          self.registerTranslationKeys(data['phrases']);
      });
    }
  },
    
  registerMissingTranslationKey: function(translation_key, token_values, options) {
    if (!this.missing_translation_keys[translation_key.key]) {
      // It is possible to have multiple different elements with the same key, but different tokens
      this.missing_translation_keys[translation_key.key] = {translation_key:translation_key, tr8n_elements:[]};
    }
    var tr8n_element = {tr8n_element_id:translation_key.element_id, token_values:token_values, options:options};
    // Tr8n.log("Registering missing key data: " + JSON.stringify(tr8n_element));
    this.missing_translation_keys[translation_key.key].tr8n_elements.push(tr8n_element);
  },

  detectLocale: function(label) {
    if (Tr8n.page_locale) 
      return Tr8n.page_locale;

    if (!Tr8n.google_api_key) 
      return Tr8n.default_locale;

    var detected_locale = Tr8n.default_locale;
    window.tr8nJQ.ajax({
      url: "https://www.googleapis.com/language/translate/v2/detect",
      method: "GET",
      async: false,
      data: {
        "key": Tr8n.google_api_key,
        "q": label
      }
    }).done(function(data) {
      if (!data["data"] || !data["data"]["detections"] || data["data"]["detections"].length == 0) 
        return Tr8n.default_locale;
      var first_detection = data["data"]["detections"][0][0];
      detected_locale = first_detection["language"];
    }).fail(function() {
      return detected_locale;
    });
    return detected_locale;
  },

  submitMissingTranslationKeys: function() {
    this.scheduler_enabled = false; // halt the scheduler

    var phrases = [];

    var keys = Object.keys(this.missing_translation_keys);
    if (keys.length == 0) {
      this.scheduler_enabled = true;
      return;
    }

    for (var i=0; i<keys.length; i++) {
      if (i>30) break; // lets do at most 50 at a time
      var missing_key = this.missing_translation_keys[keys[i]].translation_key;

      var locale = missing_key.locale || this.detectLocale(missing_key.label);
      var phrase = {label: missing_key.label, locale: locale};
      if (missing_key.description && missing_key.description.length > 0) {
        phrase.description = missing_key.description;
      }
      phrases.push(phrase);
    }
    
    var self = this;
    Tr8n.log("Submitting " + phrases.length + " missing keys...");
    
    var params = {
      source: Tr8n.source,
      phrases: JSON.stringify(phrases)
    };

    Tr8n.api('language/translate', params, function(data) {
        // Tr8n.log("Received response from the server: " + JSON.stringify(data));
        self.updateMissingTranslationKeys(data['phrases']);
    });
  },
  
  updateMissingTranslationKeys: function(translations) {
    if (!Tr8n.Utils.isArray(translations)) {
      translations = translations['phrases'];
    }

    // Tr8n.log("Received " + translations.length + " translation keys...");

    for (i=0; i<translations.length; i++) {
       var translation_key_data = translations[i];

       // Tr8n.log("Updating translation key " + JSON.stringify(translation_key_data));
       this.translations[translation_key_data.key] = translation_key_data;

       var missing_key_data = this.missing_translation_keys[translation_key_data.key];
       if (!missing_key_data) continue; // why?

       var missing_key = missing_key_data.translation_key;
       var tr8n_elements = missing_key_data.tr8n_elements;
       
       for (j=0; j<tr8n_elements.length; j++) {
          var tr8n_element_data = tr8n_elements[j];
          var tr8n_element = Tr8n.element(tr8n_element_data.tr8n_element_id);
          if (!tr8n_element) continue; 
          missing_key.original = translation_key_data.original;
          tr8n_element.setAttribute('translation_key_id', translation_key_data['id']);
           // Tr8n.log(missing_key_data.translation_key.decorationClasses());
          tr8n_element.setAttribute('class', missing_key_data.translation_key.decorationClasses());
          tr8n_element.innerHTML = missing_key.translate(this.language, tr8n_element_data.token_values, {'skip_decorations': true});
       }
       delete this.missing_translation_keys[translation_key_data.key];
    }

    var keys = Object.keys(this.missing_translation_keys);
    if (keys.length > 0) {
      this.submitMissingTranslationKeys();  
    } else {
      this.scheduler_enabled = true;
    }
  },  

  runScheduledTasks: function() {
    var self = this;
    
    if (this.scheduler_enabled) {
      this.submitMissingTranslationKeys();
    }
    
    window.setTimeout(function() {
      self.runScheduledTasks();
    }, this.options['scheduler_interval']);
  },

  initTml: function() {
    if (Tr8n.element('tr8n_status_node')) return;

    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_ALL, function(node) {
      if (node.nodeName == 'TML:LABEL') {
        return NodeFilter.FILTER_ACCEPT;
      } else {
        return NodeFilter.FILTER_SKIP;
      }
    }, false);

    while (tree_walker.nextNode()) {
      new Tr8n.SDK.TML.Label(tree_walker.currentNode).translate();
    }

    this.submitMissingTranslationKeys();
  },

  translateTextNode: function(parent_node, text_node, label) {
    // we need to handle empty spaces better
    var sanitized_label = Tr8n.Utils.sanitizeString(label);

    if (Tr8n.Utils.isNumber(sanitized_label)) return;

    // no empty strings
    if (sanitized_label == null || sanitized_label.length == 0) return;

    var translation = this.translate(sanitized_label);

    if (/^\s/.test(label)) translation = " " + translation;
    if (/\s$/.test(label)) translation = translation + " ";

    var translated_node = document.createElement("tml:label");
    translated_node.innerHTML = translation;

    // translated_node.style.border = '1px dotted red';
    parent_node.replaceChild(translated_node, text_node);
  },

  initText: function() {
    if (Tr8n.element('tr8n_status_node')) return;

    Tr8n.log("Initializing text nodes...");

    // add node to the document so it is not processed twice
    var tr8nStatusNode = document.createElement('div');
    tr8nStatusNode.id = 'tr8n_status_node';
    tr8nStatusNode.style.display = 'none';
    document.body.appendChild(tr8nStatusNode);

    var text_nodes = [];
    var tree_walker = document.createTreeWalker(document.body, NodeFilter.SHOW_TEXT, null, false);
    while (tree_walker.nextNode()) {
      text_nodes.push(tree_walker.currentNode);
    }
 
    Tr8n.log("Found " + text_nodes.length + " text nodes");

    var disable_sentences = false;

    for (var i = 0; i < text_nodes.length; i++) {
      var current_node = text_nodes[i];
      var parent_node = current_node.parentNode;
       
      if (!parent_node) continue;

      // no scripts 
      if (parent_node.tagName == "script" || parent_node.tagName == "SCRIPT") continue;
      
      var label = current_node.nodeValue || "";

      // no html image tags
      if (label.indexOf("<img") != -1) continue;

      // no comments
      if (label.indexOf("<!-") != -1) continue;

      var sentences = label.split(". ");

      if (disable_sentences || sentences.length == 1) {
        this.translateTextNode(parent_node, current_node, label);

      } else {
        var node_replaced = false;

        for (var i=0; i<sentences.length; i++) {
          var sanitized_sentence = Tr8n.Utils.sanitizeString(sentences[i]);
          if (sanitized_sentence.length == 0) continue;

          var sanitized_sentence = sanitized_sentence + ".";
          var translated_node = document.createElement("span");
          // translated_node.style.border = '1px dotted green';
          translated_node.innerHTML = this.translate(sanitized_sentence);

          if (node_replaced) {
            parent_node.appendChild(translated_node);
          } else {
            parent_node.replaceChild(translated_node, current_node);
            node_replaced = true;
          }
          parent_node.appendChild(document.createTextNode(" "));

        }
      }
    }

    this.submitMissingTranslationKeys();
  },

  debug: function() {
    var config = {
      settings: this.options,
      translations: this.translations,
      translation_queue: this.missing_translation_keys
    };
    Tr8n.UI.Lightbox.showHTML(Tr8n.Logger.objectToHtml(config), {width:700, height:600});
  },

  logSettings: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.options);
  },
  
  logTranslations: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.translations);
  },
  
  logMissingTranslations: function() {
    Tr8n.Logger.clear();
    Tr8n.Logger.logObject(this.missing_translation_keys);
  }
  
}

function reloadTranslations() { 
  Tr8n.SDK.Proxy.initTranslations(true); 
} 

function tr(label, description, tokens, options) { 
  return Tr8n.SDK.Proxy.tr(label, description, tokens, options); 
} 

function trl(label, description, tokens, options) { 
  return Tr8n.SDK.Proxy.trl(label, description, tokens, options); 
} 


Tr8n.SDK.Language = function() {

}

Tr8n.SDK.Language.prototype = {
  translate: function(label, description, tokens, options) {
    return (new Tr8n.SDK.TranslationKey(label, description).translate(this, tokens, options));
  }
}


Tr8n.SDK.TranslationKey = function(label, description, options) {
  this.id = null;                         // translation_key_id used by translator
  this.key = null;                        // unique translation key used to find elements 
  this.element_id = Tr8n.Utils.uuid();    // element id to be updated
  this.original = true;                   // by default assuming there are no translations in the cache
  this.label = label; 
  this.description = description;
  this.options = options;
  this.generateKey();
}

Tr8n.SDK.TranslationKey.prototype = {

  generateKey: function() {
    this.key = this.label + ";;;";
    if (this.description) this.key = this.key + this.description;
    this.key = MD5(this.key);
  },

  findFirstAcceptableTranslation: function(translations, token_values) {
    // check for a single translation case - no context rules
    if (translations['label']!=null) {
      // Tr8n.log('Found a single translation: ' + translations['label']);
      return translations;    
    }
  
    translations = translations['labels'];
    if (!translations) {
      Tr8n.error("Translations are in a weird form...");
      return null;
    }

    // Tr8n.log('Found translations: ' + translations.length);

    for (var i=0; i<translations.length; i++) {
      // Tr8n.log("Checking context rules for:" + translations[i]['label']);
      
      if (!translations[i]['context']) {
        // Tr8n.log("Translation has no context, using it by default");
        return translations[i];
      }
      var valid_context = true;

      for (var token in translations[i]['context']) {
        if (!valid_context) continue;
        var token_context = translations[i]['context'][token];
        var rule_name = Tr8n.SDK.Proxy.getLanguageRuleForType(token_context['type']);

        // Tr8n.log("Evaluating rule: " + rule_name);
        var rule = eval("new " + rule_name + "()");
        rule.definition = token_context;
        rule.options = {};
        valid_context = valid_context && rule.evaluate(token, token_values);
      }
      
      if (valid_context) {
        // Tr8n.log("Found valid translation: " + translations[i].label);
        return translations[i];
      } else {
        // Tr8n.log("The rules were not matched for: " + translations[i].label);
      }
    }
    
    // Tr8n.log('No acceptable ranslations found');
    return null;        
  },
  
  translate: function(language, token_values, options) {
    if (!this.label) {
      // Tr8n.log('Label must always be provided for the translate method');
      return '';
    }
    
    var translations = Tr8n.SDK.Proxy.translations;
    var translation_key = translations[this.key];

    if (translation_key) {
       // Tr8n.log("Translate: found translation key: " + JSON.stringify(translation_key));
      // Tr8n.log("Found translations, evaluating rules...");      
      
      this.id = translation_key.id;
      this.original = translation_key.original;
      var translation = this.findFirstAcceptableTranslation(translation_key, token_values);

      if (translation) {
        // Tr8n.log("Found a valid match: " + translation.label);      
        return this.substituteTokens(translation['label'], token_values, options);
      } else {
        // Tr8n.log("No valid match found, using default language");      
        return this.substituteTokens(this.label, token_values, options);
      }
      
    } else {
      // Tr8n.log("Translation not found, using default language");      
    }

    Tr8n.SDK.Proxy.registerMissingTranslationKey(this, token_values, options);
    // Tr8n.log('No translation found. Using default...');
    return this.substituteTokens(this.label, token_values, options);    
  },
  
  registerDataTokens: function(label) {
    this.data_tokens = [];
    this.data_tokens = this.data_tokens.concat(Tr8n.SDK.Tokens.DataToken.parse(label, {}));
    this.data_tokens = this.data_tokens.concat(Tr8n.SDK.Tokens.TransformToken.parse(label, {}));
  },

  registerDecorationTokens: function(label) {
    this.decoration_tokens = [];
    this.decoration_tokens = this.decoration_tokens.concat(Tr8n.SDK.Tokens.DecorationToken.parse(label, {}));
  },

  substituteTokens: function(label, token_values, options) {
    this.registerDataTokens(label);
    if (!this.data_tokens) return this.decorateLabel(label, options);
    for (var i = 0; i < this.data_tokens.length; i++) {
      label = this.data_tokens[i].substitute(label, token_values || {});
    }
    
    this.registerDecorationTokens(label);
    if (!this.decoration_tokens) return label;
    for (var i = 0; i < this.decoration_tokens.length; i++) {
      label = this.decoration_tokens[i].substitute(label, token_values || {});
    }
    
    return this.decorateLabel(label, options);
  },
  
  decorationClasses: function() {
    var klasses = [];
    klasses.push('tr8n_translatable');
    if (Tr8n.SDK.Proxy.inline_translations_enabled) {
      if (this.original)
        klasses.push('tr8n_not_translated');
      else  
        klasses.push('tr8n_translated');
    }
    return klasses.join(' ');
  },

  decorateLabel: function(label, options) {
    options = options || {};
    if (options['skip_decorations'])
      return label;
      
    html = [];
    html.push("<tr8n ");
    html.push(" id='" + this.element_id + "' ");
    
    if (this.id) 
      html.push(" translation_key_id='" + this.id + "' ");

    html.push(" class='" + this.decorationClasses() + "'");
    html.push(">");
    html.push(label);
    html.push("</tr8n>");

    return html.join("");
  }
}


Tr8n.SDK.Translation = function(translation_key, language, label, options) {
  this.translaton_key = translation_key;
  this.language = language;
  this.label = label;
  this.options = options;
}

Tr8n.SDK.Translation.prototype = {

}

Tr8n.SDK.Tokens.Base = function() {
}

Tr8n.SDK.Tokens.Base.prototype = {
  
  getExpression: function() {
    // must be implemented by the extending class
    return null;
  },

  parse: function(label, options) {
    if (this.getExpression() == null) {
      Tr8n.Logger.error("Token expression must be provided");
    }
      
    var tokens = label.match(this.getExpression());
    if (!tokens) return [];
    
    var objects = [];
    var uniq = {};
    for(i=0; i<tokens.length; i++) {
      if (uniq[tokens[i]]) continue;
      // Tr8n.log("Registering data token: " + tokens[i]);
      objects.push(new Tr8n.Proxy.TransformToken(label, tokens[i], options)); 
      uniq[tokens[i]] = true;
    }
    return objects;
  },

  getFullName: function() {
    return this.full_name;
  },

  getDeclaredName: function() {
    if (!this.declared_name) {
      this.declared_name = this.getFullName().replace(/[{}\[\]]/g, '');
    }
    return this.declared_name;
  },

  getName: function() {
    if (!this.name) {
      this.name = Tr8n.Utils.trim(this.getDeclaredName().split(':')[0]); 
    }
    return this.name;
  },

  getLanguageRule: function() {
    
    return null;
  },

  substitute: function(label, token_values) {
    var value = token_values[this.getName()];
    
    if (value == null) {
      Tr8n.Logger.error("Value for token: " + this.getFullName() + " was not provided");
      return label;
    }

    return Tr8n.Utils.replaceAll(label, this.getFullName(), this.getTokenValue(value)); 
  },

  getTokenValue: function(token_value) {
    if (typeof token_value == 'string') return token_value;
    if (typeof token_value == 'number') return token_value;
    return token_value['value'];
  },

  getTokenObject: function(token_value) {
    if (typeof token_value == 'string') return token_value;
    if (typeof token_value == 'number') return token_value;
    return token_value['subject'];
  },

  getType: function() {
    if (this.getDeclaredName().indexOf(':') == -1)
      return null;
    
    if (!this.type) {
      this.type = this.getDeclaredName().split('|')[0].split(':');
      this.type = this.type[this.type.length - 1];
    }
    
    return this.type;     
  },

  getSuffix: function() {
    if (!this.suffix) {
      this.suffix = this.getName().split('_');
      this.suffix = this.suffix[this.suffix.length - 1];
    }
    return this.suffix;
  },

  getLanguageRule: function() {
    if (!this.language_rule) {
      if (this.getType()) {
        this.language_rule = Tr8n.SDK.Proxy.getLanguageRuleForType(this.getType()); 
      } else {
        this.language_rule = Tr8n.SDK.Proxy.getLanguageRuleForTokenSuffix(this.getSuffix());
      }
    }
    return this.language_rule;
  }
}

Tr8n.SDK.Tokens.DataToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.SDK.Tokens.DataToken.prototype = new Tr8n.SDK.Tokens.Base();

Tr8n.SDK.Tokens.DataToken.parse = function(label, options) {
  var tokens = label.match(/(\{[^_][\w]+(:[\w]+)?\})/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    // Tr8n.log("Registering data token: " + tokens[i]);
    objects.push(new Tr8n.SDK.Tokens.DataToken(label, tokens[i], options));
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.SDK.Tokens.TransformToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.SDK.Tokens.TransformToken.prototype = new Tr8n.SDK.Tokens.Base();

Tr8n.SDK.Tokens.TransformToken.parse = function(label, options) {
  var tokens = label.match(/(\{[^_][\w]+(:[\w]+)?\s*\|\|?[^{^}]+\})/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    // Tr8n.log("Registering transform token: " + tokens[i]);
    objects.push(new Tr8n.SDK.Tokens.TransformToken(label, tokens[i], options)); 
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.SDK.Tokens.TransformToken.prototype.getName = function() {
  if (!this.name) {
    this.name = Tr8n.Utils.trim(this.getDeclaredName().split('|')[0].split(':')[0]); 
  }
  return this.name;
}

Tr8n.SDK.Tokens.TransformToken.prototype.getPipedParams = function() {
  if (!this.piped_params) {
    var temp = this.getDeclaredName().split('|');
    temp = temp[temp.length - 1].split(",");
    this.piped_params = [];
    for (i=0; i<temp.length; i++) {
      this.piped_params.push(Tr8n.Utils.trim(temp[i]));
    }
  }
  return this.piped_params;
}

Tr8n.SDK.Tokens.TransformToken.prototype.substitute = function(label, token_values) {
  var object = token_values[this.getName()];
  if (object == null) {
    Tr8n.Logger.error("Value for token: " + this.getFullName() + " was not provided");
    return label;
  }
  
  var token_object = this.getTokenObject(object);
  // Tr8n.log("Registered " + this.getPipedParams().length + " piped params");
  
  var lang_rule_name = this.getLanguageRule();
  
  if (!lang_rule_name) {
    Tr8n.Logger.error("Rule type cannot be determined for the transform token: " + this.getFullName());
    return label;
  } else {
    // Tr8n.log("Transform token uses rule: " + lang_rule_name);
  }

  var transform_value = eval(lang_rule_name).transform(token_object, this.getPipedParams());
  // Tr8n.log("Registered transform value: " + transform_value);
  
  // for double pipes - show the actual value as well
  if (this.isAllowedInTranslation()) {
    var token_value = this.getTokenValue(object);
    transform_value = token_value + " " + transform_value; 
  }
  
  return Tr8n.Utils.replaceAll(label, this.getFullName(), transform_value);
}

Tr8n.SDK.Tokens.TransformToken.prototype.getPipedSeparator = function() {
  if (!this.piped_separator) {
    this.piped_separator = (this.getFullName().indexOf("||") != -1 ? "||" : "|");
  }
  return this.piped_separator;
}

Tr8n.SDK.Tokens.TransformToken.prototype.isAllowedInTranslation = function(){
  return this.getPipedSeparator() == "||";
}

Tr8n.SDK.Tokens.DecorationToken = function(label, token, options) {
  this.label = label;
  this.full_name = token;
  this.options = options;
}

Tr8n.SDK.Tokens.DecorationToken.prototype = new Tr8n.SDK.Tokens.Base();

Tr8n.SDK.Tokens.DecorationToken.parse = function(label, options) {
  var tokens = label.match(/(\[\w+:[^\]]+\])/g);
  if (!tokens) return [];
  
  var objects = [];
  var uniq = {};
  for(i=0; i<tokens.length; i++) {
    if (uniq[tokens[i]]) continue;
    // Tr8n.log("Registering decoration token: " + tokens[i]);
    objects.push(new Tr8n.SDK.Tokens.DecorationToken(label, tokens[i], options));
    uniq[tokens[i]] = true;
  }
  return objects;
}

Tr8n.SDK.Tokens.DecorationToken.prototype.getDecoratedValue = function() {
  if (!this.decorated_value) {
    var value = this.getFullName().replace(/[\]]/g, '');
    value = value.substring(value.indexOf(':') + 1, value.length);
    this.decorated_value = Tr8n.Utils.trim(value);
  }
  return this.decorated_value;
}

Tr8n.SDK.Tokens.DecorationToken.prototype.substitute = function(label, token_values) {
  var object = token_values[this.getName()];
  var decoration = object;
  
  if (!object || typeof object == 'object') {
    // look for the default decoration
    decoration = Tr8n.SDK.Proxy.getDecorationFor(this.getName());
    if (!decoration) {
      Tr8n.Logger.error("Default decoration is not defined for token " + this.getName());
      return label;
    }
    
    decoration = Tr8n.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
    if (object) {
      for (var key in object) {
        decoration = Tr8n.Utils.replaceAll(decoration, '{$' + key + '}', object[key]);
      }
    }
  } else if (typeof object == 'string') {
    decoration = Tr8n.Utils.replaceAll(decoration, '{$0}', this.getDecoratedValue());
  } else {
    Tr8n.Logger.error("Unknown type of decoration token " + this.getFullName());
    return label;
  }
  
  return Tr8n.Utils.replaceAll(label, this.getFullName(), decoration);
}


Tr8n.SDK.Rules.Base = function() {

}

Tr8n.SDK.Rules.Base.prototype = {

  getTokenValue: function(token_name, token_values) {
    var object = token_values[token_name];
    if (object == null) { 
      Tr8n.Logger.error("Invalid token value for token: " + token_name);
    }
    
    return object;    
  },

  getDefinitionDescription: function() {
    var result = [];
    for (var key in this.definition)
      result.push(key + ": '" + this.definition[key] + "'");
    return "{" + result.join(", ") + "}";   
  },

  sanitizeArrayValue: function(value) {
    var results = [];
    var arr = value.split(',');
    for (var index = 0; index < arr.length; index++) {
      results.push(Tr8n.Utils.trim(arr[index]));
    }   
    return results;
  }
}


Tr8n.SDK.Rules.DateRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.DateRule.prototype = new Tr8n.SDK.Rules.Base();

Tr8n.SDK.Rules.DateRule.transform = function(object, values) {
  return "";
}

Tr8n.SDK.Rules.DateRule.prototype.evaluate = function(token, token_values) {
  return true;
}

Tr8n.SDK.Rules.GenderRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.GenderRule.prototype = new Tr8n.SDK.Rules.Base();

////////////////////////////////////////////////////////////////////////////
//  FORM: [male, female, unknown]
//  {user | registered on}
//  {user | he, she}
//  {user | he, she, he/she}
////////////////////////////////////////////////////////////////////////////

Tr8n.SDK.Rules.GenderRule.transform = function(object, values) {
  if (values.length == 1) return values[0];
  
  if (typeof object == 'string') {
    if (object == 'male') return values[0];
    if (object == 'female') return values[1];
  } else if (typeof object == 'object') {
    if (object['gender'] == 'male') return values[0];
    if (object['gender'] == 'female') return values[1];
  }

  if (values.length == 3) return values[2];
  return values[0] + "/" + values[1]; 
}

Tr8n.SDK.Rules.GenderRule.prototype.evaluate = function(token_name, token_values) {

  var object = this.getTokenValue(token_name, token_values);
  if (!object) return false;

  var gender = "";
  
  if (typeof object != 'object') {
    Tr8n.Logger.error("Invalid token value for gender based token: " + token_name + ". Token value must be an object.");
    return false;
  } 

  if (!object['subject']) {
    Tr8n.Logger.error("Invalid token subject for gender based token: " + token_name + ". Token value must contain a subject. Subject can be a string or an object with a gender.");
    return false;
  }
  
  if (typeof object['subject'] == 'string') {
    gender = object['subject'];
  } else if (typeof object['subject'] == 'object') {
    gender = object['subject']['gender'];
    if (!gender) {
      Tr8n.Logger.error("Cannot determine gender for token subject: " + token_name);
      return false;
    }
  } else {
    Tr8n.Logger.error("Invalid token subject for gender based token: " + token_name + ". Subject does not have a gender.");
    return false;
  }
  
  if (this.definition['operator'] == "is") {
     return (gender == this.definition['value']);
  } else if (this.definition['operator'] == "is_not") {
     return (gender != this.definition['value']);
  }
  
  return false;
}


Tr8n.SDK.Rules.NumericRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.NumericRule.prototype = new Tr8n.SDK.Rules.Base();

/////////////////////////////////////////////////////////////////////////////////
// English based transform method
// FORM: [singular, plural]
// {count | message, messages}
// {count | person, people}
/////////////////////////////////////////////////////////////////////////////////

Tr8n.SDK.Rules.NumericRule.transform = function(count, values) {
  if (count == 1) return values[0];
  if (values.length == 2) {
    return values[1];
  }
  return values[0].pluralize();  
}

/////////////////////////////////////////////////////////////////////////////////
//  "count":{"value1":"2,3,4","operator":"and","type":"number","multipart":true,"part2":"does_not_end_in","value2":"12,13,14","part1":"ends_in"}
/////////////////////////////////////////////////////////////////////////////////

Tr8n.SDK.Rules.NumericRule.prototype.evaluate = function(token_name, token_values) {
  
  var object = this.getTokenValue(token_name, token_values);
  if (object == null) return false;

  var token_value = null;
  if (typeof object == 'string' || typeof object == 'number') {
    token_value = "" + object;
  } else if (typeof object == 'object' && object['subject']) { 
    token_value = "" + object['subject'];
  } else {
    Tr8n.Logger.error("Invalid token value for numeric token: " + token_name);
    return false;
  }
  
  // Tr8n.log("Rule value: '" + token_value + "' for definition: " + this.getDefinitionDescription());
  
  var result1 = this.evaluatePartialRule(token_value, this.definition['part1'], this.sanitizeArrayValue(this.definition['value1']));
  if (this.definition['multipart'] == 'false' || this.definition['multipart'] == false || this.definition['multipart'] == null) return result1;
  // Tr8n.log("Part 1: " + result1 + " Processing part 2...");

  var result2 = this.evaluatePartialRule(token_value, this.definition['part2'], this.sanitizeArrayValue(this.definition['value2']));
  // Tr8n.log("Part 2: " + result2 + " Completing evaluation...");
  
  if (this.definition['operator'] == "or") return (result1 || result2);
  return (result1 && result2);
}


Tr8n.SDK.Rules.NumericRule.prototype.evaluatePartialRule = function(token_value, name, values) {
  if (name == 'is') {
    if (Tr8n.Utils.indexOf(values, token_value)!=-1) return true; 
    return false;
  }
  if (name == 'is_not') {
    if (Tr8n.Utils.indexOf(values, token_value)==-1) return true; 
    return false;
  }
  if (name == 'ends_in') {
    for(var i=0; i<values.length; i++) {
      if (token_value.match(values[i] + "$")) return true;
    }
    return false;
  }
  if (name == 'does_not_end_in') {
    for(var i=0; i<values.length; i++) {
      if (token_value.match(values[i] + "$")) return false;
    }
    return true;
  }
  return false;
}

Tr8n.SDK.Rules.ListRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.ListRule.prototype = new Tr8n.SDK.Rules.Base();

Tr8n.SDK.Rules.ListRule.transform = function(object, values) {
  return "";
}

Tr8n.SDK.Rules.ListRule.prototype.evaluate = function(token, token_values) {
  return true;
}

Tr8n.SDK.Rules.GenderListRule = function(definition, options) {
  this.definition = definition;
  this.options = options;
}

Tr8n.SDK.Rules.GenderListRule.prototype = new Tr8n.SDK.Rules.Base();

Tr8n.SDK.Rules.GenderListRule.transform = function(object, values) {
  return "";
}

Tr8n.SDK.Rules.GenderListRule.prototype.evaluate = function(token, token_values) {
  return true;
}


Tr8n.SDK.TML.Label = function(node) {
  this.node = node;
  this.label = "";
  this.description = "";
  this.tokens = {};
  this.options = {};

  for (var i=0; i < this.node.childNodes.length; i++) {
    var childNode = this.node.childNodes[i];

    // text should just be added to the label
    if (childNode.nodeType == 3) {
      this.label = this.label + " " + Tr8n.Utils.trim(childNode.nodeValue);
    } else if (childNode.nodeName == "TML:TOKEN") {
      var token = new Tr8n.SDK.TML.Token(childNode, this.tokens);
      this.label = Tr8n.Utils.trim(this.label) + " " + token.toTokenString();
    }
    
  }

  this.description = this.node.attributes['desc'] || this.node.attributes['description']; 
  this.description = this.description ? this.description.value : null;

  this.label = this.label.replace(/\n/g, '');
  this.label = Tr8n.Utils.trim(this.label);

  this.options["locale"] = this.node.attributes['locale']; 
  this.options["skip_decorations"] = this.node.attributes['skip_decorations']; 
  // console.log(this.label + " : " + this.description);
}

Tr8n.SDK.TML.Label.prototype = {
  translate: function() {
    this.node.innerHTML = Tr8n.SDK.Proxy.translate(this.label, this.description, this.tokens, this.options);
  }
}


Tr8n.SDK.TML.Token = function(node, tokens) {
  this.node = node;
  
  this.type = this.node.attributes['type'];
  this.type = this.type ? this.type.value : 'data';

  this.name = this.node.attributes['name'];
  this.name = this.name ? this.name.value : 'unknown';
  this.name = this.name.toLowerCase();

  this.context = this.node.attributes['context'];
  this.context = this.context ? this.context.value : null;

  this.content = "";

  for (var i=0; i < this.node.childNodes.length; i++) {
    var childNode = this.node.childNodes[i];
    // Tr8n.log(childNode.nodeType + " " + childNode.nodeValue);
    var token_type = this.node.attributes['type'] ? this.node.attributes['type'].nodeValue : 'data';
    // Tr8n.log(this.name + " " + token_type);

    if (childNode.nodeType == 3) {
      // text should just be added to the label
      // <tml:label>You have <tml:token type="data" name="count" context="number">2</tml:token> messages.</tml:label>    
      
      if (node.attributes['context'] && node.attributes['context'].nodeValue == 'gender') {
        tokens[this.name] = {subject: node.attributes['value'].nodeValue, value: Tr8n.Utils.trim(childNode.nodeValue)};
      } else {
        tokens[this.name] = Tr8n.Utils.trim(childNode.nodeValue);
      }

    } else {
      // the first element inside the token must be a decoration span, bold, etc...
      // <tml:label>Hello 
      //   <tml:token type="decoration" name="span">
      //     <span style='color:brown;font-weight:bold;'>
      //       World
      //     </span>
      //   </tml:token> 
      // </tml:label>

      var html_tag = childNode.nodeName.toLowerCase();
      var attributes = [];
      if (childNode.attributes['style']) {
        attributes.push("style='" + childNode.attributes['style'].nodeValue + "'");
      }
      if (childNode.attributes['class']) {
        attributes.push("class='" + childNode.attributes['class'].nodeValue + "'");
      }

      tokens[this.name] = "<" + html_tag + " " + attributes.join(' ') + ">{$0}</" + html_tag + ">";

      // console.log(this.name + " has value of " + tokens[this.name]);

      this.content = "";

      for (var j=0; j<childNode.childNodes.length; j++) {
        var grandChildNode = childNode.childNodes[j];
        if (grandChildNode.nodeType == 3) {
          this.content = Tr8n.Utils.trim(this.content) + " " + Tr8n.Utils.trim(grandChildNode.nodeValue);
        } else if (grandChildNode.nodeName == "TML:TOKEN") {
          var token = new Tr8n.SDK.TML.Token(grandChildNode, tokens);
          this.content = Tr8n.Utils.trim(this.content) + " " + token.toTokenString();
        }    
      }
    }
  }

  this.content = this.content.replace(/\n/g, '');
  this.content = Tr8n.Utils.trim(this.content);
}

Tr8n.SDK.TML.Token.prototype = {
  
  toTokenString: function() {
    if (this.type == "data") {
      // TODO: we may need to add dependencies here: gender, number and language cases
      return "{" + this.name + "}";
    } else {
      return "[" + this.name + ": " + this.content + "]";
    }
  }
  
}

Tr8n.UI.LanguageSelector = {

  options: {},
  keyboardMode: false,
  loaded: false,
  container: null,

  init: function(options) {
    this.options = options || {};
  },

  initContainer: function() {
    if (this.container) return;

    this.keyboardMode = false;
    this.loaded = false;

    this.container                = document.createElement('div');
    this.container.className      = 'tr8n_language_selector';
    this.container.id             = 'tr8n_language_selector';
    this.container.style.display  = "none";

    document.body.appendChild(this.container);
  },

  toggle: function() {
    this.initContainer();

    if (this.container.style.display == "none") {
      this.show();
    } else {
      this.hide();
    }
  },

  hide: function() {
    if (!this.container) return;

    this.container.style.display = "none";
    Tr8n.Utils.showFlash();
  },

  show: function(lightbox) {
    if (lightbox) { 
      Tr8n.UI.Lightbox.show('/tr8n/language/select?lightbox=true', {height:500, width:400});
      return;
    }

    this.initContainer();

    var self = this;
    
    Tr8n.UI.Translator.hide();
    Tr8n.UI.Lightbox.hide();
    Tr8n.Utils.hideFlash();

    var splash_screen = Tr8n.element('tr8n_splash_screen');

    if (!this.loaded) {
      var html = "";
      if (splash_screen) {
        html += splash_screen.innerHTML;
      } else {
        html += "<div style='font-size:18px;text-align:center; margin:5px; padding:10px; background-color:black;'>";
        html += "  <img src='/assets/tr8n/tr8n_logo.jpg' style='width:280px; vertical-align:middle;'>";
        html += "  <img src='/assets/tr8n/loading3.gif' style='width:200px; height:20px; vertical-align:middle;'>";
        html += "</div>";
      }
      this.container.innerHTML = html;
    }
    this.container.style.display  = "block";

    var trigger             = Tr8n.element('tr8n_language_selector_trigger');
    var trigger_position    = Tr8n.Utils.cumulativeOffset(trigger);
    var container_position  = {
      left: trigger_position[0] + trigger.offsetWidth - this.container.offsetWidth + 'px',
      top: trigger_position[1] + trigger.offsetHeight + 4 + 'px'
    }

//    if (trigger_position[0] < window.innerWidth/2 ) {
//      this.container.offsetLeft = trigger_position[0] + 'px';
//    }

    this.container.style.left     = container_position.left;
    this.container.style.top      = container_position.top;

    if (!this.loaded) {
      window.setTimeout(function() {
        Tr8n.Utils.update('tr8n_language_selector', '/tr8n/language/select', {
          evalScripts: true
        })
      }, 100);
    }

    this.loaded = true;
  },

  removeLanguage: function(language_id) {
    Tr8n.Utils.update('tr8n_language_lists', '/tr8n/language/lists', {
      parameters: {language_action: "remove", language_id: language_id},
      method: 'post'
    });
  },

  change: function(locale) {
    Tr8n.UI.Lightbox.show('/tr8n/language/change?locale=' + locale, {width:400, height:480, message:"Changing language..."});      
  },

  toggleInlineTranslations: function() {
    if (Tr8n.inline_translations_enabled) {
        Tr8n.UI.Lightbox.show('/tr8n/language/toggle_inline_translations', {width:400, height:480, message:"Disabling inline translations..."});      
    } else {
        Tr8n.UI.Lightbox.show('/tr8n/language/toggle_inline_translations', {width:400, height:480, message:"Enabling inline translations..."});      
    }
  }
}

Tr8n.UI.Lightbox = {
  
  options: {},  
  container: null,
  overlay: null,
  content_frame: null,

  init: function() {

  },

  initContainer: function() {
    if (this.container) return;

    this.container                = document.createElement('div');
    this.container.className      = 'tr8n_lightbox';
    this.container.id             = 'tr8n_lightbox';
    this.container.style.height   = "100px";
    this.container.style.display  = "none";

    this.overlay                  = document.createElement('div');
    this.overlay.className        = 'tr8n_lightbox_overlay';
    this.overlay.id               = 'tr8n_lightbox_overlay';
    this.overlay.style.display    = "none";

    this.content_frame              = document.createElement('iframe');
    this.content_frame.src          = 'about:blank';
    this.content_frame.style.border = '0px';
    this.content_frame.style.width  = '100%';
    this.container.appendChild(this.content_frame);

    document.body.appendChild(this.container);
    document.body.appendChild(this.overlay);
  },

  hide: function() {
    if (!this.container) return;

    this.container.style.display = "none";
    this.overlay.style.display = "none";
    this.content_frame.src = 'about:blank';
    Tr8n.Utils.showFlash();
  },

  showHTML: function(content, opts) {
    this.initContainer();

    var self = this;
    opts = opts || {};

    Tr8n.UI.Translator.hide();
    Tr8n.UI.LanguageSelector.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.src = 'about:blank';

    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    opts["height"] = opts["height"] || 400;

    this.container.style.width        = opts["width"] + 'px';
    this.container.style.marginLeft   = -opts["width"]/2 + 'px';
    this.resize(opts["height"]);
    this.container.style.display      = "block";

    window.setTimeout(function() {
      var iframe_doc = self.content_frame.contentWindow.document;
      iframe_doc.body.setAttribute('style', 'background-color:white;padding:10px;margin:0px;font-size:10px;font-family:Arial;');

      Tr8n.Utils.insertCSS(Tr8n.host + "/assets/tr8n/tr8n.css", iframe_doc.body);
      Tr8n.Utils.insertScript(Tr8n.host + "/assets/tr8n/tr8n.js", function() {
        self.content_frame.contentWindow.Tr8n.host = Tr8n.host;
        self.content_frame.contentWindow.Tr8n.Logger.object_keys = Tr8n.Logger.object_keys;
        
        var div = document.createElement("div");
        div.innerHTML = content;
        iframe_doc.body.appendChild(div);
      }, iframe_doc.body);

    }, 1);
  },

  show: function(url, opts) {
    this.initContainer();

    var self = this;
    opts = opts || {};

    Tr8n.UI.Translator.hide();
    Tr8n.UI.LanguageSelector.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.src = Tr8n.Utils.toUrl('/tr8n/help/splash_screen', {msg: opts['message'] || 'Loading...'});

    this.overlay.style.display  = "block";

    opts["width"] = opts["width"] || 700;
    var default_height = 100;

    this.container.style.width        = opts["width"] + 'px';
    this.container.style.marginLeft   = -opts["width"]/2 + 'px';
    this.resize(default_height);

    this.container.style.display      = "block";

    window.setTimeout(function() {
      self.content_frame.src = Tr8n.Utils.toUrl(url);
    }, 500);
  },

  resize: function(height) {
    // this.container.style.marginTop    = -height/2 + 'px';
    // Tr8n.Effects.animateHeight(this.container, height);
    // Tr8n.Effects.animateHeight(this.content_frame, height);

    this.container.style.height       = height + 'px';
    this.container.style.marginTop    = -height/2 + 'px';
    this.content_frame.style.height   = height + 'px';
  }
}


Tr8n.UI.Translator = {
  options: {},
  translation_key_id: null,
  suggestion_tokens: null,
  container_width: 400,
  container: null,
  stem_image: null, 
  content_frame: null,

  init: function() {
    var self = this;

    Tr8n.Utils.addEvent(document, Tr8n.Utils.isOpera() ? 'click' : 'contextmenu', function(e) {
      if (Tr8n.Utils.isOpera() && !e.ctrlKey) return;

      var translatable_node = Tr8n.Utils.findElement(e, ".tr8n_translatable");
      var language_case_node = Tr8n.Utils.findElement(e, ".tr8n_language_case");

      var link_node = Tr8n.Utils.findElement(e, "a");

      if (translatable_node == null && language_case_node == null) return;

      // We don't want to trigger links when we right-mouse-click them
      if (link_node) {
        var temp_href = link_node.href;
        var temp_onclick = link_node.onclick;
        link_node.href='javascript:void(0);';
        link_node.onclick = void(0);
        setTimeout(function() { 
          link_node.href = temp_href; 
          link_node.onclick = temp_onclick; 
        }, 500);
      }

      if (e.stop) e.stop();
      if (e.preventDefault) e.preventDefault();
      if (e.stopPropagation) e.stopPropagation();

      if (language_case_node)
        self.show(language_case_node, true);
      else 
        self.show(translatable_node, false);

      return false;
    });
  },

  initContainer: function() {
    if (this.container) return;

    this.container                = document.createElement('div');
    this.container.className      = 'tr8n_translator';
    this.container.id             = 'tr8n_translator';
    this.container.style.display  = "none";
    this.container.style.width    = "400px";

    this.stem_image = document.createElement('img');
    this.stem_image.src = Tr8n.host + '/assets/tr8n/top_left_stem.png';
    this.container.appendChild(this.stem_image);

    this.content_frame = document.createElement('iframe');
    this.content_frame.src = 'about:blank';
    this.content_frame.style.border = '0px';
    this.container.appendChild(this.content_frame);

    document.body.appendChild(this.container);
  },

  hide: function() {
    if (!this.container) return;

    this.container.style.display = "none";
    this.content_frame.src = 'about:blank';
    Tr8n.Utils.showFlash();
  },

  show: function(translatable_node, is_language_case) {
    this.initContainer();

    var self = this;
    Tr8n.UI.LanguageSelector.hide();
    Tr8n.UI.Lightbox.hide();
    Tr8n.Utils.hideFlash();

    this.content_frame.style.width = '100%';
    this.content_frame.style.height = '10px';
    this.content_frame.src = Tr8n.Utils.toUrl('/tr8n/language/translator_splash_screen');

    var stem = {v: "top", h: "left", width: 10, height: 12};
    var label_rect = Tr8n.Utils.elementRect(translatable_node);
    var new_container_origin = {left: label_rect.left, top: (label_rect.top + label_rect.height + stem.height)}
    var stem_offset = label_rect.width/2;
    var label_center = label_rect.left + label_rect.width/2;

    // check if the lightbox will be on the left or on the right
    if (label_rect.left + label_rect.width + window.innerWidth/2 > window.innerWidth) {
      new_container_origin.left = label_rect.left + label_rect.width - this.container_width;
      stem.h = "right";
      if (new_container_origin.left + 20 > label_center) {
        new_container_origin.left = label_center - 150;
        stem_offset = new_container_origin.left - 200;
      }
    } 

    this.stem_image.className = 'stem ' + stem.v + "_" + stem.h;
    
    if (stem.h == 'left') {
      this.stem_image.style.left = stem_offset + 'px';
      this.stem_image.style.right = '';
    } else {
      this.stem_image.style.right = stem_offset + 'px';
      this.stem_image.style.left = '';
    }

    window.scrollTo(label_rect.left, label_rect.top - 100);

    this.container.style.left     = new_container_origin.left + "px";
    this.container.style.top      = new_container_origin.top + "px";
    this.container.style.display  = "block";

    window.setTimeout(function() {
      var url = '';
      var params = {};
      if (is_language_case) {
        self.language_case_id = translatable_node.getAttribute('case_id');
        self.language_case_rule_id = translatable_node.getAttribute('rule_id');
        self.language_case_key = translatable_node.getAttribute('case_key');
        url = '/tr8n/language_cases/manager';
        params['case_id'] = self.language_case_id;
        params['rule_id'] = self.language_case_rule_id;
        params['case_key'] = self.language_case_key;
      } else {
        self.translation_key_id = translatable_node.getAttribute('translation_key_id');
        url = '/tr8n/language/translator';
        params['translation_key_id'] = self.translation_key_id;
      }
      self.content_frame.src = Tr8n.Utils.toUrl(url, params);
    }, 500);
  },

  resize: function(height) {
    this.content_frame.style.height = height + 'px';
    this.container.style.height = height + 'px';
  }

}


Tr8n.Translation = {

  suggestion_key_id: null,  
  suggestion_tokens: [],

  report: function(translation_key, translation_id) {
    // TODO: wrap in trl
    var msg = "Reporting this translation will remove it from this list and the translator will be put on a watch list. \n\nAre you sure you want to report this translation?";
    if (!confirm(msg)) return;
    Tr8n.TranslatorHelper.vote(translation_key, translation_id, -1000);
  },

  vote: function(translation_key_id, translation_id, vote) {
    Tr8n.Effects.hide('tr8n_votes_for_' + translation_id);
    Tr8n.Effects.show('tr8n_spinner_for_' + translation_id);

    // the long version updates and reorders translations - used in translator and phrase list
    // the short version only updates the total results - used everywhere else
    if (Tr8n.element('tr8n_translator_votes_for_' + translation_key_id)) {
      Tr8n.Utils.update('tr8n_translator_votes_for_' + translation_key_id, '/tr8n/translations/vote', {
        parameters: { translation_id: translation_id, vote: vote },
        method: 'post'
      });
    } else {
      Tr8n.Utils.update('tr8n_votes_for_' + translation_id, '/tr8n/translations/vote', {
        parameters: { translation_id: translation_id, vote: vote, short_version: true },
        method: 'post',
        onComplete: function() {
          Tr8n.Effects.hide('tr8n_spinner_for_' + translation_id);
          Tr8n.Effects.show('tr8n_votes_for_' + translation_id);
        }
      });
    }
  },

  insertDecorationToken: function(token, text_area_id) {
    text_area_id = text_area_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.wrapText(text_area_id, "[" + token + ": ", "]");
  },

  insertToken: function(token, text_area_id) {
    text_area_id = text_area_id || 'tr8n_translator_translation_label';
    Tr8n.Utils.insertAtCaret(text_area_id, "{" + token + "}");
  },

  submit: function() {
    Tr8n.Effects.hide('tr8n_translator_translation_container');
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  lock: function() {
    Tr8n.Effects.hide('tr8n_translator_translations_container');
    Tr8n.Effects.hide('tr8n_translator_footer_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  submitWithDependencies: function() {
    Tr8n.Effects.hide('tr8n_translator_buttons_container');
    Tr8n.Effects.hide('tr8n_translator_dependencies_container');
    Tr8n.Effects.show('tr8n_translator_spinner');
    Tr8n.element('tr8n_translator_form').action = '/tr8n/translations/lock';
    Tr8n.Effects.submit('tr8n_translator_form');
  },

  suggest: function(translation_key_id, original, tokens, from_lang, to_lang) {
    if (Tr8n.google_api_key == null) return;
    
    this.suggestion_tokens = tokens;
    this.suggestion_key_id = translation_key_id;

    var new_script = document.createElement('script');
    new_script.type = 'text/javascript';
    var source_text = escape(original);
    var api_source = 'https://www.googleapis.com/language/translate/v2?key=' + Tr8n.google_api_key;
    var source = api_source + '&source=' + from_lang + '&target=' + to_lang + '&callback=Tr8n.Translation.showSuggestion&q=' + source_text;
    new_script.src = source;
    document.getElementsByTagName('head')[0].appendChild(new_script);
  },

  showSuggestion: function(response) {
    if (response == null ||response.data == null || response.data.translations==null || response.data.translations.length == 0) 
      return;
    var suggestion = response.data.translations[0].translatedText;

    if (this.suggestion_tokens) {
      var tokens = this.suggestion_tokens.split(",");
      this.suggestion_tokens = null;

      for (var i=0; i<tokens.length; i++) {
        suggestion = Tr8n.Utils.replaceAll(suggestion, "(" + i + ")", tokens[i]);
      }
    }  

    Tr8n.element("tr8n_translation_suggestion_" + this.suggestion_key_id).innerHTML = suggestion;

    if (Tr8n.element('tr8n_translator_translation_label')) {
      Tr8n.element('tr8n_translator_translation_label').value = suggestion;  
    }

    Tr8n.element("tr8n_google_suggestion_container_" + this.suggestion_key_id).style.display = "block";
    var suggestion_section = Tr8n.element('tr8n_google_suggestion_section');
    if (suggestion_section) suggestion_section.style.display = "block";
  }
  
}


window.Tr8n = window.$tr8n = Tr8n.Utils.extend(Tr8n, {
  element     : Tr8n.Utils.element,
  value       : Tr8n.Utils.value,
  log         : Tr8n.Logger.log,
  getStatus   : Tr8n.SDK.Auth.getStatus,
  connect     : Tr8n.SDK.Auth.connect,
  disconnect  : Tr8n.SDK.Auth.disconnect,
  logout      : Tr8n.SDK.Auth.logout,
  api         : Tr8n.SDK.Api.get          //most api calls are gets
});

Tr8n.init();

   
