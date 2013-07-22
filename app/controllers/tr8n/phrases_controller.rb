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

class Tr8n::PhrasesController < Tr8n::BaseController

  before_filter :validate_current_translator
  before_filter :validate_default_language, :except => [:translate, :vote]
  before_filter :init_sitemap_section, :except => [:translate, :vote]
  
  def index
    # In the embedded mode - there should be only one application
    begin
      @selected_application = send(:tr8n_selected_application)
    rescue 
      @selected_application = Tr8n::Config.current_application
    end

    sources = sources_from_params

    if sources.any?
      @selected_application = sources.first.application
      @translation_keys = Tr8n::TranslationKey.for_params(params.merge(:application => @selected_application))
      @translation_keys = translation_keys_for_sources(sources, @translation_keys)
      return
    end

    @translation_keys = Tr8n::TranslationKey.for_params(params.merge(:application => @selected_application))

    # get a list of all restricted keys
    restricted_keys = Tr8n::TranslationKey.all_restricted_ids

    # exclude all restricted keys
    if restricted_keys.any?
      @translation_keys =  @translation_keys.where("id not in (?)", restricted_keys)
    end

    @translated = Tr8n::Config.current_language.total_metric.translation_completeness
    @locked = Tr8n::Config.current_language.completeness
    @translation_keys = @translation_keys.order("created_at desc").page(page).per(per_page)
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
    
    @translations = Tr8n::Translation.for_params(params)
    @translations = @translations.where("tr8n_translations.language_id = ? and tr8n_translations.translation_key_id = ?", tr8n_current_language.id,  @translation_key.id)
    @translations = @translations.order("rank desc, created_at desc")
    @comments = Tr8n::TranslationKeyComment.where("language_id = ? and translation_key_id = ?", tr8n_current_language.id, @translation_key.id).order("created_at desc").page(page).per(per_page)
    
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
    render_lightbox
  end
    
  def recalculate_metric
    metric = Tr8n::TranslationSourceMetric.find_by_id(params[:id])
    unless metric
      trfe("Invalid metric id")
      return redirect_to_source
    end

    metric.update_metrics!
    redirect_to_source
  end

private

  def sources_from_params
    # unless params[:section_key].blank?
    #   return sitemap_sources_for(@section_key) 
    # end

    unless params[:sources].blank?
      source_ids = params[:sources].split(',')
      return [] if source_ids.empty?
      return Tr8n::TranslationSource.where("id in (?)", source_ids).all
    end    

    unless params[:source_id].blank?
      source = Tr8n::TranslationSource.find_by_id(params[:source_id])
      return [] unless source
      return [source]
    end

    unless params[:component_id].blank?
      @component = Tr8n::Component.find_by_id(params[:component_id])
      return [] unless @component
      return @component.sources
    end

    []
  end

  def translation_keys_for_sources(sources, keys)
    @selected_sources = []
    @translated = 0
    @locked = 0

    source_ids = []
    sources.each do |source|
      next unless source.translator_authorized?
      source_ids << source.id
      @selected_sources << source
      @locked += (source.total_metric.completeness || 0)
      @translated += (source.total_metric.translation_completeness || 0)
    end

    # avg of the total
    if source_ids.empty?
      @translated = 0
      @locked = 0
      return keys.where("tr8n_translation_keys.id = -1") 
    end

    @locked = @locked/source_ids.size
    @translated = @translated/source_ids.size
    pp source_ids
    keys = keys.joins(:translation_sources).where("tr8n_translation_sources.id in (?)", source_ids.uniq).uniq
    # where("(tr8n_translation_keys.id in (select distinct(tr8n_translation_key_sources.translation_key_id) from tr8n_translation_key_sources where tr8n_translation_key_sources.translation_source_id in (?)))", source_ids.uniq)
    keys.order("tr8n_translation_keys.created_at desc").page(page).per(per_page)
  end

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