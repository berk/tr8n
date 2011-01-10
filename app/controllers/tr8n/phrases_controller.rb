#--
# Copyright (c) 2010 Michael Berkovich, Geni Inc
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

class Tr8n::PhrasesController < Tr8n::BaseController

  before_filter :validate_current_translator
  before_filter :validate_default_language, :except => [:translate, :vote]
  before_filter :init_sitemap_section, :except => [:translate, :vote]
  
  def index
    conditions = Tr8n::TranslationKey.search_conditions_for(params)
   
    unless params[:section_key].blank?
      source_names = sitemap_sources_for(@section_key)
      pp source_names
      sources = Tr8n::TranslationSource.find(:all, :conditions => ["source in (?)", source_names])
      source_ids = sources.collect{|source| source.id}
      
      if source_ids.empty?
        conditions = ["1=2"]
      else  
        conditions[0] << " and " unless conditions[0].blank?
        conditions[0] << "(id in (select distinct(translation_key_id) from tr8n_translation_key_sources where translation_source_id in (?)))"
        conditions << source_ids.uniq
      end
    end
    
    @translation_keys = Tr8n::TranslationKey.paginate(:per_page => per_page, :page => page, :conditions => conditions, :order => "label asc")    
  end
  
  def view
    @translation_key = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
    @translation_key = Tr8n::TranslationKey.random if params[:dir] == "random"

    unless @translation_key
      trfe("This phrase could not be found")
      return redirect_to_site_default_url
    end
    
    @show_add_dialog = (params[:mode] == "add" or @translation_key.translations_for(tr8n_current_language).empty?)

    # for new translation
    @translation = Tr8n::Translation.new(:translation_key => @translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    @rules = {}
    
    conditions = Tr8n::Translation.search_conditions_for(params)
    
    conditions[0] << " and " unless conditions[0].blank?
    conditions[0] << "tr8n_translations.language_id = ? and tr8n_translations.translation_key_id = ?"
    conditions << tr8n_current_language.id
    conditions << @translation_key.id
    
    @translations = Tr8n::Translation.find(:all, :conditions => conditions, :order => "rank desc, created_at desc")
    @comments = Tr8n::TranslationKeyComment.paginate(:page => page, :per_page => per_page, 
                      :conditions => ["language_id = ? and translation_key_id = ?", tr8n_current_language.id, @translation_key.id], 
                      :order => "created_at desc")
    
    @grouping = {}
    if params[:grouped_by] != "nothing"
      @translations.each do |tr|
        case params[:grouped_by]
          when "translator" then
              if tr.translator.user
                key = trl("Translations Created by {user}", "", :user => [tr.translator.user, tr.translator.name])
              else
                key = trl("Translations Created by an Unknown User")
              end
              (@grouping[key] ||= []) << tr 
          when "context" then
              if tr.context.blank?
                key = trl("Translations Without Context Rules")
              else
                key = tr.context
              end
              (@grouping[key] ||= []) << tr 
          when "rank" then
              key = trl("Translations With Rank \"{rank}\"", "", :rank => tr.rank)
              (@grouping[key] ||= []) << tr 
          when "date" then
              key = trl("Translations Created On {date}", "", :date => tr.created_at.trl(:verbose))
              (@grouping[key] ||= []) << tr 
        end
      end
    end
    
  end
  
  # main translation method used by the translator and translation screens
  def translate
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translations = @translation_key.translations_for(tr8n_current_language)
    @source_url = params[:source_url] || request.env['HTTP_REFERER']
    
    unless request.post?
      trfe("Please use a translator window for submitting translations")
      return redirect_to(@source_url)
    end

    if params[:translation_has_dependencies] == "true" # comes from inline translator only
      @translation_key.generate_rule_permutations(tr8n_current_language, tr8n_current_translator, params[:dependencies])
      trfn("We have created all possible combinations of the values for the tokens. Please provide a translation for each combination.")
      return redirect_to(:controller => "/tr8n/phrases", :action => :view, :translation_key_id => @translation_key.id, :submitted_by => :me, :submitted_on => :today)
    end
    
    if params[:translation_id].blank?
      @translation = Tr8n::Translation.new(:translation_key => @translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    else  
      @translation = Tr8n::Translation.find(params[:translation_id])
    end
    
    @translation.label = sanitize_label(params[:translation][:label])
    @translation.rules = parse_rules
    
    unless @translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to update translation which is locked or belongs to another translator")
      trfe("You are not authorized to edit this translation")
      return redirect_to(@source_url)
    end  
    
    unless @translation.clean?
      tr8n_current_translator.used_abusive_language!
      trfe("Your translation contains prohibited words and will not be accepted")
      return redirect_to(@source_url)
    end

    @translation.save_with_log!(tr8n_current_translator)
    @translation.reset_votes!(tr8n_current_translator)

    redirect_to(@source_url)
  end
  
  def vote
    @translation = Tr8n::Translation.find(params[:translation_id])
    @translation.vote!(tr8n_current_translator, params[:vote])
    @translation_key = @translation.translation_key

    # this is called from page translations page
    if params[:short_version]
      return render(:text => @translation.rank_label) 
    end
    
    # this is called from the inline translator with reordering the translations based on ranks
    @translations = @translation_key.inline_translations_for(tr8n_current_language)
    render(:partial => '/tr8n/common/translation_votes', :locals => {:translation_key => @translation_key, :translations => @translations, :section_key => ""})
  end
    
  #  ajax based method for updating individual translations
  def update
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
          if @translation.clean?
            @translation.save_with_log!(tr8n_current_translator)
            @translation.reset_votes!(tr8n_current_translator)
          else
            tr8n_current_translator.used_abusive_language!
            @translation.label = "Your translation contains prohibited words and will not be accepted. Click on cancel and try again."
            mode = :edit
          end
        end

      end
    end
    render :partial => "translation", :locals => {:translation => @translation, :mode => mode, :show_actions => true}
  end  
  
  def delete
    translation = Tr8n::Translation.find(params[:translation_id])
    translator = translation.translator

    unless translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to delete translation that is not his")
      trfe("You are not authorized to delete this translation as you were not it's creator")
    else
      translation.destroy_with_log!(tr8n_current_translator)
      translator.update_rank!
      trfn("Your translation has been removed.")
    end
    
    redirect_to(:action => :key, :translation_key_id => translation.translation_key.id, :section_key => @section_key)
  end

  def lock
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translation_key.lock!
    redirect_to(:action => :view, :translation_key_id => @translation_key.id)
  end

  def unlock
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translation_key.unlock!
    redirect_to(:action => :view, :translation_key_id => @translation_key.id)
  end

  def map
    @section_key = "map"
  end
    
  def dictionary
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @definitions = Tr8n::Dictionary.load_definitions_for(@translation_key.words)
    render :partial => "dictionary", :layout => false
  end
  
  def submit_comment
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    Tr8n::TranslationKeyComment.create(:language => tr8n_current_language, 
                                       :translator => tr8n_current_translator, 
                                       :translation_key => @translation_key,
                                       :message => params[:message])

    trfn("Your comment has been added.")
    
    redirect_to_source
  end

  def delete_comment
    comment = Tr8n::TranslationKeyComment.find_by_id(params[:comment_id]) unless params[:comment_id].blank?
    comment.destroy if comment
    
    trfn("Your comment has been removed.")
    
    redirect_to_source
  end

  def lb_sources
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    render :layout => false
  end
    
private

  def init_sitemap_section
    return if params[:section_key].blank?
    @section_key = params[:section_key]
    @section = Tr8n::SiteMap.section_for_key(@section_key)    
  end
  
  def sitemap_sources_for(key)
    section = Tr8n::SiteMap.section_for_key(key)
    sources = []
    section = collect_sitemap_section_sources(section, sources)
    sources.flatten.uniq
  end
  
  def collect_sitemap_section_sources(section, sources)
    sources << section.sources if section.sources
    section.children.each do |section|
      collect_sitemap_section_sources(section, sources)
    end
  end  
  
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