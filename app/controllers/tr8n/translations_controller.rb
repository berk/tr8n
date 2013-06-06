#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8nhub.com
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

class Tr8n::TranslationsController < Tr8n::BaseController

  before_filter :validate_current_translator
  before_filter :validate_default_language, :except => [:submit, :permutate, :vote]
  
  # for ssl access to the translator - using ssl_requirement plugin  
  ssl_allowed :submit  if respond_to?(:ssl_allowed)
  
  # list of translations    
  def index
    # In the embedded mode - there should be only one application
    begin
      @selected_application = send(:tr8n_selected_application)
    rescue 
      @selected_application = Tr8n::Config.current_app
    end

    @translations = Tr8n::Translation.for_params(params.merge(:application => @selected_application, :only_phrases => true))
    @translations = @translations.order("created_at desc, rank desc").page(page).per(per_page)
    # restricted_keys = Tr8n::TranslationKey.all_restricted_ids

    # # exclude all restricted always
    # if restricted_keys.any?
    #   @translations = @translations.where("translation_key_id not in (?)", restricted_keys)
    # end

    # @followed_translators = tr8n_current_translator.followed_objects("Tr8n::Translator")
    # unless [nil, "", "anyone", "me"].include?(params[:submitted_by])
    #   translator = Tr8n::Translator.find_by_id(params[:submitted_by])  
    #   if translator
    #     if translator == tr8n_current_translator
    #       params[:submitted_by] = :me
    #     elsif not @followed_translators.include?(translator)
    #       @followed_translators << translator
    #     end
    #   end
    # end

    # @translations = Tr8n::Translation.for_params(params).order("created_at desc, rank desc").page(page).per(per_page)
  end

  # main translation method used by the translator and translation screens
  def submit
    return redirect_to_source unless request.post?

    destination_url = params[:destination_url] || {:controller => '/tr8n/tools/translator', :action => 'done', :translation_key_id => params[:translation_key_id], :origin => params[:origin]}

    translation_key = Tr8n::TranslationKey.find_by_id(params[:translation_key_id].to_i)
    unless translation_key
      trfe("Invalid translation key id")
      return redirect_to(destination_url)
    end

    if params[:lock] == "true"
      if tr8n_current_translator.manager?
        if translation_key.locked?
          translation_key.unlock!
        else
          translation_key.lock!
        end
      else
        trfe("You are not authorized to lock translation keys")
      end
      return redirect_to(destination_url)
    end

    if params[:translation_id].blank?
      translation = Tr8n::Translation.new(:translation_key => translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    else  
      translation = Tr8n::Translation.find_by_id(params[:translation_id].to_i)
      unless translation
        trfe("Invalid translation id")
        return redirect_to(destination_url)
      end
    end

    translation.label = sanitize_label(params[:translation][:label])
    translation.rules = parse_rules

    unless translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation which is locked or belongs to another translator")
      trfe("You are not authorized to edit this translation")
      return redirect_to(destination_url)
    end  

    if translation.blank?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an empty translation")
      trfe("Your translation was empty and was not accepted")
      return redirect_to(destination_url)
    end
    
    unless translation.uniq?
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an identical translation")
      trfe("There already exists such translation for this phrase. Please vote on it instead or suggest an elternative translation.")
      return redirect_to(destination_url)
    end
    
    unless translation.clean?
      tr8n_current_translator.used_abusive_language!
      trfe("Your translation contains prohibited words and will not be accepted")
      return redirect_to(destination_url)
    end

    translation.save_with_log!(tr8n_current_translator)
    translation.reset_votes!(tr8n_current_translator)

    redirect_to(destination_url)
  end
  
  # generates phrase context rules permutations
  # can be called from the translator or from a page
  def permutate
    return redirect_to_source unless request.post?
    
    translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])

    if params[:translator]
      destination_url = {:controller => '/tr8n/tools/translator', :action => :permutations, :translation_key_id => translation_key.id, :origin => params[:origin]}
    else
      destination_url = {:controller => "/tr8n/phrases", :action => :view, :translation_key_id => translation_key.id, :grouped_by => :context}
    end

    new_translations = translation_key.generate_rule_permutations(tr8n_current_language, tr8n_current_translator, params[:dependencies])

    if params[:translator]
      ids = new_translations.collect{|trn| trn.id}
      destination_url.merge!(:ids => ids.join(','))
    else
      if params[:dependencies].blank?
        trfe("No context rules were specified.")
      elsif new_translations.nil? or new_translations.empty?
        trfn("The context rules already exist. Please provide a translation for each rule.")
      else
        trfn("All possible combinations of the context rules for this phrase have been generated. Please provide a translation for each rule.")
      end  
    end
    
    redirect_to(destination_url)
  end
  
  # ajax based method - collects votes for a translation
  def vote
    translation = Tr8n::Translation.find(params[:translation_id])
    translation.vote!(tr8n_current_translator, params[:vote])
    translation_key = translation.translation_key

    # this is called from page translations page
    if params[:short_version] == "true"
      return render(:text => translation.rank_label) 
    end
    
    # this is called from the inline translator with reordering the translations based on ranks
    translations = translation_key.inline_translations_for(tr8n_current_language)
    render(:partial => '/tr8n/common/translation_votes', :locals => {:translation_key => translation_key, :translations => translations, :section_key => ""})
  end

  # ajax based method for updating individual translations
  def update
    #coming from translator window
    if params[:translations]
      translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
      params[:translations].each do |tid, label|
        trn = Tr8n::Translation.find_by_id(tid)
        next unless trn
        trn.label = sanitize_label(label)
        next unless trn.can_be_edited_by?(tr8n_current_translator)
        next if trn.blank?
        next unless trn.uniq?
        next unless trn.clean?
        trn.save_with_log!(tr8n_current_translator)
        trn.reset_votes!(tr8n_current_translator)
      end
      return redirect_to(:controller => '/tr8n/language', :action => :translator, :mode => :done, :translation_key_id => translation_key.id, :origin => params[:origin])
    end

    @translation = Tr8n::Translation.find(params[:translation_id])
    mode = params[:mode] || :view
    if request.post?
      mode = :view
      unless params[:label].strip.blank?
        @translation.label = sanitize_label(params[:label])
        
        unless @translation.can_be_edited_by?(tr8n_current_translator)
          tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation that is not his")
          @translation.label = "You are not authorized to edit this translation as you were not it's creator"
          mode = :edit
        else 
          if @translation.blank?
            tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an empty translation")
            @translation.label = "Your translation was empty and was not accepted"
            mode = :edit
          elsif not @translation.uniq?
            tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to submit an identical translation")
            @translation.label = "There already exists such translation for this phrase. Please vote on it instead or suggest an elternative translation."
            mode = :edit
          elsif not @translation.clean?
            tr8n_current_translator.used_abusive_language!
            @translation.label = "Your translation contains prohibited words and will not be accepted. Click on cancel and try again."
            mode = :edit
          else
            @translation.save_with_log!(tr8n_current_translator)
            @translation.reset_votes!(tr8n_current_translator)
          end
        end

      end
    end
    render(:partial => "translation", :locals => {:language => tr8n_current_language, :translation => @translation, :mode => mode.to_sym})
  end  
  
  # deletes an individual translation
  def delete
    translation = Tr8n::Translation.find(params[:translation_id])
    translator = translation.translator

    unless translation.can_be_deleted_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to delete translation that is not his")
      trfe("You are not authorized to delete this translation as you were not it's creator")
    else
      translation.destroy_with_log!(tr8n_current_translator)
      translator.update_rank!
      trfn("Your translation has been removed.")
    end
    
    redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => translation.translation_key.id, :section_key => @section_key)
  end
    
private

  def parse_rules
    return nil unless params[:has_rules] == "true" and params[:rules] 
    
    rulz = []
    params[:rules].keys.each do |token|
      next unless params[:rules][token][:selected] == "true" 
      rulz << {:token => token, :rule_id => params[:rules][token][:rule_id]}
    end
    rulz
  end

end