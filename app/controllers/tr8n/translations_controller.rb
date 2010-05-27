class Tr8n::TranslationsController < Tr8n::BaseController

  before_filter :validate_current_translator
  before_filter :validate_default_language, :except => [:translate, :vote]
  before_filter :init_sitemap_section, :except => [:translate, :vote]
  
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
      return redirect_to(:controller => "/tr8n/translations", :action => :key, :translation_key_id => @translation_key.id, :submitted_by => :me, :submitted_on => :today)
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
    
  def index
    conditions = [""]
    
    unless params[:search].blank?
      conditions[0] << "(tr8n_translation_keys.label like ? or tr8n_translation_keys.description like ?)" 
      conditions << "%#{params[:search]}%"
      conditions << "%#{params[:search]}%"  
    end
    
    if params[:with_translations] == "with"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "tr8n_translation_keys.id in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ? "
      conditions << tr8n_current_language.id
      
      if params[:submitted_by] == "me"
        conditions[0] << " and tr8n_translations.translator_id = ?" 
        conditions << tr8n_current_translator.id
      end

      if params[:submitted_on] == "today"
        date = Date.today
        conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
        conditions << date
        conditions << (date + 1.day)
      elsif params[:submitted_on] == "yesterday"
        date = Date.today - 1.day
        conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
        conditions << date
        conditions << (date + 1.day)
      elsif params[:submitted_on] == "last_week"
        date = Date.today - 7.days
        conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
        conditions << date
        conditions << Date.today
      end
      
      conditions[0] << ")"
    elsif params[:with_translations] == "without"
      conditions[0] << " and " unless conditions[0].blank?
      conditions[0] << "tr8n_translation_keys.id not in (select tr8n_translations.translation_key_id from tr8n_translations where tr8n_translations.language_id = ?)"
      conditions << tr8n_current_language.id
    end
    
    unless params[:section_key].blank?
      source_names = sitemap_sources_for(@section_key)
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
    
  def key
    @translation_key = Tr8n::TranslationKey.find_by_id(params[:translation_key_id])
    @translation_key = Tr8n::TranslationKey.random if params[:dir] == "random"
    @translations = @translation_key.translations_for(tr8n_current_language)
    if @translations.empty? and not @translation_key.locked?
      return redirect_to(:action => :view, :translation_key_id => @translation_key.id, :source => :translations, :section_key => @section_key)
    end
    
    conditions = ["tr8n_translations.language_id = ? and tr8n_translations.translation_key_id = ?"]
    conditions << tr8n_current_language.id
    conditions << @translation_key.id
    
    unless params[:search].blank?
      conditions[0] << " and tr8n_translations.label like ?" 
      conditions << "%#{params[:search]}%"
    end
    
    if params[:submitted_by] == "me"
      conditions[0] << " and tr8n_translations.translator_id = ?" 
      conditions << tr8n_current_translator.id
    end

    if params[:submitted_on] == "today"
      date = Date.today
      conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
      conditions << date
      conditions << (date + 1.day)
    elsif params[:submitted_on] == "yesterday"
      date = Date.today - 1.day
      conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
      conditions << date
      conditions << (date + 1.day)
    elsif params[:submitted_on] == "last_week"
      date = Date.today - 7.days
      conditions[0] << " and tr8n_translations.created_at >= ? and tr8n_translations.created_at < ?" 
      conditions << date
      conditions << Date.today
    end
    
    order = params[:ordered_by] || "rank"
    group = params[:grouped_by] || "none"
    @translations = Tr8n::Translation.find(:all, :conditions => conditions, :order => "#{order} desc")
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
    render :partial => "translation", :locals => {:translation => @translation, :mode => mode}
  end  
  
  def view
    if params[:translation_id]
      @translation = Tr8n::Translation.find(params[:translation_id])
      @translation_key = @translation.translation_key
    else
      @translation_key = Tr8n::TranslationKey.find_by_id(params[:translation_key_id]) 
      @translation = Tr8n::Translation.new(:translation_key => @translation_key, :language => tr8n_current_language, :translator => tr8n_current_translator)
    end

    if @translation_key.locked?
      trfe("This translation key is locked and can no longer be translated")
      return redirect_to(:action => :key, :translation_key_id => @translation_key.id, :section_key => @section_key)
    end

    @source_url = "/tr8n/translations/key?translation_key_id=#{@translation_key.id}&section_key=#{@section_key}"
    @cancel_url = @source_url
    @cancel_url = {:action => :index, :section_key => @section_key} if params[:source]
    
    @rules = {}
    if @translation.rules
      @translation.rules.each do |rule|
        @rules[rule[:token]] = rule[:rule_id]
      end
    end
  end
  
  def delete
    @translation = Tr8n::Translation.find(params[:translation_id])

    unless @translation.can_be_edited_by?(tr8n_current_translator)
      tr8n_current_translator.tried_to_perform_unauthorized_action!("tried to delete translation that is not his")
      trfe("You are not authorized to delete this translation as you were not it's creator")
    else  
      @translation.destroy_with_log!(tr8n_current_translator)
      trfn("Your translation has been removed.")
    end
    
    redirect_to(:action => :key, :translation_key_id => @translation.translation_key.id, :section_key => @section_key)
  end

  def lock_key
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translation_key.lock!
    redirect_to(:action => :key, :translation_key_id => @translation_key.id)
  end

  def unlock_key
    @translation_key = Tr8n::TranslationKey.find(params[:translation_key_id])
    @translation_key.unlock!
    redirect_to(:action => :key, :translation_key_id => @translation_key.id)
  end

  def map
    @section_key = "map"
  end
    
private

  def init_sitemap_section
    return if params[:section_key].blank?
    
    @section_key = params[:section_key]
    @section = sitemap_section_for(@section_key)
    @section[:key] = @section_key
    @section
  end

  def sitemap_section_for(key)
    key_hash = {}
    Tr8n::Config.sitemap_sections.each do |section|
      next unless section[:enabled]
      generate_sitemap_keys(section[:sections], key_hash)
    end
    key_hash[key]
  end
  
  def generate_sitemap_keys(sections, key_hash)
    sections.each do |section|
      key = Tr8n::TranslationKey.generate_key(section[:label], section[:description])
      key_hash[key] = section
      if section[:sections] and section[:sections].size > 0
        generate_sitemap_keys(section[:sections], key_hash)
      end  
    end
  end
  
  def sitemap_sources_for(key)
    section = sitemap_section_for(key)
    sources = []
    section = collect_sitemap_section_sources(section, sources)
    sources.flatten.uniq
  end
  
  def collect_sitemap_section_sources(section, sources)
    sources << section[:sources] if section[:sources]
    if section[:sections]
      section[:sections].each do |section|
        collect_sitemap_section_sources(section, sources)
      end
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