module Tr8n::KeyboardMapping

  def self.current
    [{:key => "Arabic", :name => "Arabic"},
    {:key => "Armenian East", :name => "Armenian"},
    {:key => "Armenian West", :name => "Armenian"},
    {:key => "Belarusian", :name => "Belarusian"},
    {:key => "Belgian", :name => "Belgian"},
    {:key => "Bengali", :name => "Bengali"},
    {:key => "Bulgarian Ph", :name => "Bulgarian"},
    {:key => "Burmese", :name => "Burmese"},
    {:key => "Czech", :name => "Czech"},
    {:key => "Danish", :name => "Danish"},
    {:key => "Dutch", :name => "Dutch"},
    {:key => "Dvorak", :name => "Dvorak"},
    {:key => "Farsi", :name => "Farsi"},
    {:key => "French", :name => "French"},
    {:key => "German", :name => "German"},
    {:key => "Greek", :name => "Greek"},
    {:key => "Hebrew", :name => "Hebrew"},
    {:key => "Hindi", :name => "Hindi"},
    {:key => "Hungarian", :name => "Hungarian"},
    {:key => "Italian", :name => "Italian"},
    {:key => "日本語", :name => "Japanese"},
    {:key => "Kazakh", :name => "Kazakh"},
    {:key => "Lithuanian", :name => "Lithuanian"},
    {:key => "Macedonian", :name => "Macedonian"},
    {:key => "Norwegian", :name => "Norwegian"},
    {:key => "Numpad", :name => "Numpad"},
    {:key => "Pashto", :name => "Pashto"},
    {:key => "Pinyin", :name => "Pinyin"},
    {:key => "Polish Prog", :name => "Polish"},
    {:key => "Portuguese Br", :name => "Portuguese"},
    {:key => "Portuguese Pt", :name => "Portuguese"},
    {:key => "Romanian", :name => "Romanian"},
    {:key => "Russian", :name => "Russian"},
    {:key => "SerbianCyr", :name => "Serbian"},
    {:key => "SerbianLat", :name => "Serbian"},
    {:key => "Slovak", :name => "Slovak"},
    {:key => "Slovenian", :name => "Slovenian"},
    {:key => "Spanish Es", :name => "Spanish"},
    {:key => "Swedish", :name => "Swedish"},
    {:key => "Turkish-F", :name => "Turkish"},
    {:key => "Turkish-Q", :name => "Turkish"},
    {:key => "UK", :name => "English"},
    {:key => "Ukrainian", :name => "Ukrainian"},
    {:key => "US", :name => "English"},
    {:key => "US Int'l", :name => "US Int'l"}].each do |pair|
      return pair[:key] if pair[:name] == Tr8n::Config.current_language.english_name.split(" ").first
    end
    
    return "US Int'l"
  end  
end
