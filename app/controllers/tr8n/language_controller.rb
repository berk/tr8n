#--
# Copyright (c) 2010-2011 Michael Berkovich, tr8n.net
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
#++

module Tr8n
  class LanguageController < Tr8n::BaseController

    before_filter :validate_guest_user, :except => [:select, :switch, :translator_splash_screen, :toggle_inline_translations, :change, :table]
    before_filter :validate_current_translator, :except => [:select, :switch, :translator_splash_screen, :toggle_inline_translations, :change, :table]
    before_filter :validate_language_management, :only => [:index]
    
    # for ssl access to the translator - using ssl_requirement plugin  
    ssl_allowed :translator, :select, :lists, :switch, :remove  if respond_to?(:ssl_allowed)

    def index
      @rules = rules_by_dependency(tr8n_current_language.rules)
      @cases = tr8n_current_language.cases
      @fallback_language = (tr8n_current_language.fallback_language || tr8n_default_language)
    end

    def update_language_section
      @cases = tr8n_current_language.cases
      @rules = rules_by_dependency(tr8n_current_language.rules)
      @fallback_language = (tr8n_current_language.fallback_language || tr8n_default_language)

      unless request.post?
        return render(:partial => params[:section], :locals => {:mode => params[:mode].to_sym})
      end
    
      @error_msg = validate_language
      if @error_msg
        return render(:partial => params[:section], :locals => {:mode => params[:mode].to_sym})
      end

      tr8n_current_language.update_attributes(params[:language])
    
      if params[:section] == 'grammar'
        old_rule_ids = tr8n_current_language.rules.collect{|rule| rule.id}
        parse_language_rules.each do |rule|
          rule.language = tr8n_current_language
          rule.save_with_log!(tr8n_current_translator)
          old_rule_ids.delete(rule.id)
        end

        # clean up the remaining/deleted rules
        old_rule_ids.each do |id| 
          rule = Tr8n::LanguageRule.find(id)
          rule.destroy_with_log!(tr8n_current_translator)
        end
      
        Tr8n::Cache.delete("language_rules_#{tr8n_current_language.id}") 
      end
    
      if params[:section] == 'language_cases'
        # remove old cases
        tr8n_current_language.cases.each do |lcase|
          lcase.destroy
        end
      
        # create new cases
        parse_language_cases.each do |lcase|
          lcase.language = tr8n_current_language
          lcase.save_with_log!(tr8n_current_translator)
        end

        Tr8n::Cache.delete("language_cases_#{tr8n_current_language.id}") 
      end
    
      tr8n_current_language.reload
    
      @rules = rules_by_dependency(tr8n_current_language.rules)
      @cases = tr8n_current_language.cases
      @fallback_language = (tr8n_current_language.fallback_language || tr8n_default_language)

      render(:partial => params[:section], :locals => {:mode => :view})
    end
  
    # ajax method for updating language rules in edit mode
    def update_rules
      @rules = rules_by_dependency(parse_language_rules)
    
      unless params[:rule_action]
        return render(:partial => "edit_rules")
      end

      if params[:rule_action].index("add_at")
        position = params[:rule_action].split("_").last.to_i
        cls = Tr8n::Config.language_rule_dependencies[params[:rule_type]]
        @rules[cls.dependency].insert(position, cls.new(:language => tr8n_current_language))
      elsif params[:rule_action].index("delete_at")
        position = params[:rule_action].split("_").last.to_i
        cls = Tr8n::Config.language_rule_dependencies[params[:rule_type]]
        @rules[cls.dependency].delete_at(position)
      end
    
      render :partial => "edit_rules"      
    end
  
    # ajax method for updating language cases in edit mode
    def update_language_cases
      @cases = parse_language_cases
    
      unless params[:case_action]
        return render(:partial => "edit_cases")
      end
  
      if params[:case_action].index("add_at")
        position = params[:case_action].split("_").last.to_i
        @cases.insert(position, Tr8n::LanguageCase.new(:language => tr8n_current_language))
      elsif params[:case_action].index("delete_at")
        position = params[:case_action].split("_").last.to_i
        @cases.delete_at(position)
      elsif params[:case_action].index("clear_all")
        @cases = []
      end
    
      render :partial => "edit_language_cases"      
    end
  
    # ajax method for updating language case rules in edit mode
    def update_language_case_rules
      cases = parse_language_cases
      case_index = params[:case_index].to_i
      lcase = cases[case_index]

      if params[:case_action].index("add_rule_at")
        position = params[:case_action].split("_").last.to_i
        rule_data = params[:edit_rule].merge(:language => tr8n_current_language)
        lcase.language_case_rules.insert(position, Tr8n::LanguageCaseRule.new(rule_data))
      
      elsif params[:case_action].index("update_rule_at")
        position = params[:case_action].split("_").last.to_i
        rule_data = params[:edit_rule].merge(:language => tr8n_current_language)
        lcase.language_case_rules[position].definition = params[:edit_rule][:definition]

      elsif params[:case_action].index("move_rule_up_at")
        position = params[:case_action].split("_").last.to_i
        temp_node = lcase.language_case_rules[position-1]
        lcase.language_case_rules[position-1] = lcase.language_case_rules[position]
        lcase.language_case_rules[position] = temp_node              

      elsif params[:case_action].index("move_rule_down_at")
        position = params[:case_action].split("_").last.to_i
        temp_node = lcase.language_case_rules[position+1]
        lcase.language_case_rules[position+1] = lcase.language_case_rules[position]
        lcase.language_case_rules[position] = temp_node              
              
      elsif params[:case_action].index("delete_rule_at")
        position = params[:case_action].split("_").last.to_i
        lcase.language_case_rules.delete_at(position)
      
      elsif params[:case_action].index("clear_all")
        lcase.language_case_rules = []
      
      end
    
      render(:partial => "edit_language_case_rules", :locals => {:lcase => lcase, :case_index => case_index})
    end
  
  
    # language selector window
    def select
      @inline_translations_allowed = false
      @inline_translations_enabled = false
    
      if tr8n_current_user_is_translator? 
        unless tr8n_current_translator.blocked?
          @inline_translations_allowed = true
          @inline_translations_enabled = tr8n_current_translator.enable_inline_translations?
        end
      else
        @inline_translations_allowed = Tr8n::Config.open_registration_mode?
      end
    
      @inline_translations_allowed = true if tr8n_current_user_is_admin?
    
      @source_url = request.env['HTTP_REFERER']
      @source_url.gsub!("locale", "previous_locale") if @source_url
    
      @all_languages = Tr8n::Language.enabled_languages
      @user_languages = Tr8n::LanguageUser.languages_for(tr8n_current_user) unless tr8n_current_user_is_guest?
    
      if params[:lightbox]
        render :partial => "select"
      else
        render :layout => false
      end      
    end
  
    # language selector management functions
    def lists
      if request.post? 
        if params[:language_action] == "remove"
          lu = Tr8n::LanguageUser.find(:first, :conditions => ["language_id = ? and user_id = ?", params[:language_id].to_i, tr8n_current_user.id])
          lu.destroy
        end
      end
    
      @all_languages = Tr8n::Language.enabled_languages
      @user_languages = Tr8n::LanguageUser.languages_for(tr8n_current_user)
      render(:partial => "lists")  
    end
  
    def remove
      lu = Tr8n::LanguageUser.find(:first, :conditions => ["language_id = ? and user_id = ?", params[:language_id].to_i, tr8n_current_user.id])
      lu.destroy if lu
      redirect_to_source
    end
  
    def enable_inline_translations
      tr8n_current_translator.enable_inline_translations!
      redirect_to_source
    end

    def disable_inline_translations
      tr8n_current_translator.disable_inline_translations!
      redirect_to_source
    end

    # language selector processor
    def switch
      language_action = params[:language_action]
    
      return redirect_to_source if tr8n_current_user_is_guest?
    
      if tr8n_current_user_is_translator? # translator mode
        if language_action == "toggle_inline_mode"
          if tr8n_current_translator.enable_inline_translations?
            language_action = "disable_inline_mode"
          else      
            language_action = "enable_inline_mode"
          end
        end
      
        if language_action == "enable_inline_mode"
          tr8n_current_translator.enable_inline_translations!
        elsif language_action == "disable_inline_mode"
          tr8n_current_translator.disable_inline_translations!
        elsif language_action == "switch_language"
          tr8n_current_translator.switched_language!(Tr8n::Language.find_by_locale(params[:locale]))
        end   
      elsif language_action == "switch_language"  # non-translator mode
        Tr8n::LanguageUser.create_or_touch(tr8n_current_user, Tr8n::Language.find_by_locale(params[:locale]))
      elsif language_action == "become_translator" # non-translator mode
        Tr8n::Translator.register
      elsif language_action == "enable_inline_mode" or language_action == "toggle_inline_mode" # non-translator mode
        Tr8n::Translator.register.enable_inline_translations!
      end
    
      redirect_to_source
    end

    # change language from lightbox
    def change
      Tr8n::LanguageUser.create_or_touch(tr8n_current_user, Tr8n::Language.find_by_locale(params[:locale]))
      render(:layout => false)
    end

    # toggle inline translations popup window
    def toggle_inline_translations
      # redirect to login if not a translator
      unless tr8n_current_user_is_guest?
        tr8n_current_translator.toggle_inline_translations!
      end
      render(:layout => false)
    end

    # inline translator popup window as well as translation backend method
    def translator
      if params[:translation_key_id]
        @translation_key = Tr8n::TranslationKey.find_by_id(params[:translation_key_id].to_i)
        @translations = @translation_key.inline_translations_for(tr8n_current_language)
        @translation = Tr8n::Translation.default_translation(@translation_key, tr8n_current_language, tr8n_current_translator)
        @mode = params[:mode] || (@translations.empty? ? 'submit' : 'votes')
      else  
        @mode = 'done'
      end
      render(:layout => false)
    end
    
    def translator_splash_screen
      render :layout => false
    end

    def table
      @source_url = params[:source_url] || request.env['HTTP_REFERER']
    end
  
    def lb_language_case_rule
      @case = Tr8n::LanguageCase.new(params[:case])
      @rule_index = params[:rule_index]
    
      if params[:case_action].index("add_rule_at")
        @rule = Tr8n::LanguageCaseRule.new(:definition => {})
        @new_rule = true
      else
        @rule = Tr8n::LanguageCaseRule.new(params[:rule])
      end
    
      render :layout => false
    end
  
  private

    # parse with safety - we don't want to disconnect existing translations from those rules
    def parse_language_rules
      rulz = []
      return rulz unless params[:rules]
    
      Tr8n::Config.language_rule_classes.each do |cls|
        next unless params[:rules][cls.dependency]
        index = 0    
        while params[:rules][cls.dependency]["#{index}"]
          rule_params = params[:rules][cls.dependency]["#{index}"]
          rule_definition = params[:rules][cls.dependency]["#{index}"][:definition]
        
          if rule_params.delete(:reset_values) == "true"
            rule_definition = {}
          end
  
          rule_id = rule_params[:id]
        
          if rule_id.blank?
            rulz << cls.new(:definition => rule_definition)
          else
            rule = cls.find_by_id(rule_id)
            rule = cls.new unless rule
            rule.definition = rule_definition
            rulz << rule
          end
          index += 1
        end
    
      end 
    
      rulz
    end

    def parse_language_cases
      cases = []
      return cases unless params[:cases]
    
      case_index = 0  
      while params[:cases]["#{case_index}"]
        case_rules = params[:cases]["#{case_index}"].delete("rules")
        lcase = Tr8n::LanguageCase.new(params[:cases]["#{case_index}"])
        rules = []
      
        if case_rules
          rule_index = 0
          while case_rules["#{rule_index}"]
            rule_data = case_rules["#{rule_index}"].merge(:id => nil, :language_case => lcase, :language => tr8n_current_language, :translator => tr8n_current_translator, :position => rule_index)
            rules << Tr8n::LanguageCaseRule.new(rule_data)
            rule_index += 1
          end
        end
      
        lcase.language_case_rules = rules      
        cases << lcase
        case_index += 1
      end
    
      cases
    end

    def rules_by_dependency(rules)
      types = {}
      Tr8n::Config.language_rule_classes.each do |cls|
        types[cls.dependency] = []
      end 

      rules.each{|rule| (types[rule.class.dependency] ||= []) << rule}
      types
    end
  
    def case_index
      (params[:case_index] || 0).to_i
    end

    def rule_index
      (params[:rule_index] || 0).to_i
    end

  end
end