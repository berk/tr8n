module Tr8n::HelperMethods
  include Tr8n::CommonMethods

  def tr8n_options_for_select(options, selected = nil, description = nil, lang = Tr8n::Config.current_language)
    options_for_select(options.tro(description), selected)
  end

  def tr8n_phrases_link_tag(search = "", phrase_type = :without, phrase_status = :any)
    return unless Tr8n::Config.enabled?
    return if Tr8n::Config.current_language.default?
    return unless Tr8n::Config.open_registration_mode? or Tr8n::Config.current_user_is_translator?
    return unless Tr8n::Config.current_translator.enable_inline_translations?
    
    link_to(image_tag("/tr8n/images/translate_icn.gif", :style => "vertical-align:middle; border: 0px;", :title => search), 
           :controller => "/tr8n/phrases", :action => :index, 
           :search => search, :phrase_type => phrase_type, :phrase_status => phrase_status)
  end

  def tr8n_splash_screen_tag
    html = "<div id='tr8n_splash_screen' style='display:none'>"
    html << (render :partial => Tr8n::Config.splash_screen)
    html << "</div>"
  end

  def tr8n_language_name_tag(lang = Tr8n::Config.current_language, opts = {})
    show_flag = opts[:flag].nil? ? true : opts[:flag]
    name_type = opts[:name].nil? ? :full : opts[:name] # :full, :native, :english, :locale
    linked = opts[:linked].nil? ? true : opts[:linked] 
    
    html = "<span style='white-space: nowrap'>"
    if show_flag
      html << image_tag("/tr8n/images/flags/#{lang.flag}.png", :style => "vertical-align:middle;", :title => trl("#{lang.english_name} flag"))
    end
    
    html << "&nbsp;" 
    name = case name_type
      when :native  then lang.native_name
      when :english then lang.english_name
      when :locale  then lang.locale
      else lang.full_name
    end
    
    if linked
      html << link_to(name, :controller => "/tr8n/language", 
              :action => :switch, :language_action => :switch_language, 
              :locale => lang.locale,
              :source_url => opts[:source_url])
    else    
      html << name
    end
    
    html << "</span>"
  end

  def tr8n_language_selector_tag
    render(:partial => '/tr8n/common/language_selector')    
  end

  def tr8n_language_strip_tag(opts = {})
    opts[:flag] = opts[:flag].nil? ? false : opts[:flag]
    opts[:name] = opts[:name].nil? ? :native : opts[:name] 
    opts[:linked] = opts[:linked].nil? ? true : opts[:linked] 
    opts[:javascript] = opts[:javascript].nil? ? false : opts[:javascript] 
    
    render(:partial => '/tr8n/common/language_strip', :locals => {:opts => opts})    
  end

  def tr8n_language_table_tag(opts = {})
    opts[:cols] = opts[:cols].nil? ? 3 : opts[:cols]
    opts[:col_size] = opts[:col_size].nil? ? "300px" : opts[:col_size]
    render(:partial => '/tr8n/common/language_table', :locals => {:opts => opts})    
  end
  
  def tr8n_scripts_tag
    render(:partial => '/tr8n/common/scripts')    
  end

  def tr8n_translator_rank_tag(translator, rank = nil)
    return "" unless translator
    
    rank ||= translator.rank || 0
    
    html = ""
    1.upto(5) do |i|
      if rank > i * 20 - 10  and rank < i * 20  
        html << image_tag("/tr8n/images/rating_star05.png")
      elsif rank < i * 20 - 10 
        html << image_tag("/tr8n/images/rating_star0.png")
      else
        html << image_tag("/tr8n/images/rating_star1.png")
      end 
    end
    
    html    
  end
  
  def tr8n_help_icon_tag(filename = "index")
    link_to(image_tag("/tr8n/images/help.png", :style => "border:0px; vertical-align:middle;", :title => trl("Help")), {:controller => "/tr8n/help", :action => filename}, :target => "_new")
  end
  
  def tr8n_help_link(text, opts = {})
    filename = opts[:filename].nil? ? text.downcase.gsub(' ', '_') : opts[:filename] 
    classname = "tr8n_selected" if filename == controller.action_name
    link_to(text, { :controller => "/tr8n/help", :action => filename }, :class => classname)
  end

  def tr8n_spinner_tag(id = "spinner", label = nil, cls='spinner')
    html = "<div id='#{id}' class='#{cls}' style='display:none'>"
    html << image_tag("/tr8n/images/spinner.gif", :style => "vertical-align:middle;")
    html << " #{trl(label)}" if label
    html << "</div>"
  end
  
  def tr8n_toggler_tag(content_id, label = "", open = true)
    html = "<span id='#{content_id}_open' "
    html << "style='display:none'" unless open
    html << ">"
    html << link_to_function("#{image_tag("/tr8n/images/arrow_down.gif", :style=>'text-align:center; vertical-align:middle')} #{label}", "$('#{content_id}_open').hide(); $('#{content_id}_closed').show(); Effect.BlindUp('#{content_id}', { duration: 0.2 });", :style=> "text-decoration:none")
    html << "</span>" 
    html << "<span id='#{content_id}_closed' "
    html << "style='display:none'" if open
    html << ">"
    html << link_to_function("#{image_tag("/tr8n/images/arrow_right.gif", :style=>'text-align:center; vertical-align:middle')} #{label}", "$('#{content_id}_open').show(); $('#{content_id}_closed').hide(); Effect.BlindDown('#{content_id}', { duration: 0.2 });", :style=> "text-decoration:none")
    html << "</span>" 
  end  
  
  def tr8n_sitemap(sections, splitters, options = {})
    html = ""
    html << "<table style='width:100%'>"
    html << "<tr>"
    splitters.each do |splitter| 
      html << "<td style='vertical-align:top; width:" << (100 / splitters.size).to_s << "%;'>"
      html << generate_sitemap(sections[splitter.first..splitter.last], options)      
      html << "</td>"
    end 
    html << "</tr>"
    html << "</table>"
  end
  
  def tr8n_user_tag(translator, options = {})
    return "Deleted Translator" unless translator
    
    if options[:linked]
      link_to(translator.name, translator.user_link)
    else
      translator.name
    end
  end

  def tr8n_user_mugshot_tag(translator, options = {})
    if translator
      img_url = translator.user_mugshot
    else
      img_url = Tr8n::Config.silhouette_image
    end
    
    img_tag = "<img src='#{img_url}' style='width:48px'>"
    
    if translator and options[:linked]
      link_to(img_tag, translator.user_link)
    else  
      img_tag
    end
  end  
  
  # overloaded plugin methods 
  
  def will_paginate(collection = nil, options = {})
    super(collection, options.merge(:previous_label => tr("{left_quote} Previous", "Previous entries in a list", 
                                    {:left_quote => "&laquo;"}, options), 
                                    :next_label => tr("Next {right_quote}", "Next entries in a list", 
                                    {:right_quote => "&raquo;"}, options)))
  end

  def page_entries_info(collection, options = {})
    entry_name = options[:entry_name] ||
      (collection.empty?? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
    
    if collection.total_pages < 2
      case collection.size
      when 0; tr("No #{entry_name.pluralize} found", 
                 "Paginator no entries message", {}, options)
        
      when 1; tr("Displaying [bold: 1] #{entry_name}", 
                 "Paginator one page message", {}, options)
                 
      else;   tr("Displaying [bold: all {count}] #{entry_name.pluralize}", 
                 "Paginator all entries message", {:count => collection.size}, options)
      end
    else
      tr("Displaying #{entry_name.pluralize} [bold: {start_num} - {end_num}] of [bold: {total_count}] in total", 
         "Paginator custom message", {
            :start_num    => collection.offset + 1,
            :end_num      => collection.offset + collection.length,
            :total_count  => collection.total_entries
         }, options
      )
    end
  end

  def will_filter
    html = render(:partial => "/model_filter/filter", :locals => {:model_filter => @model_filter})
    html << "<br>"
    html
  end

private

  def generate_sitemap(sections, options = {})
    html = "<ul class='section_list'>"
    sections.each do |section|
      key = Tr8n::TranslationKey.generate_key(section[:label], section[:description])
      
      html << "<li class='section_list_item'>" 
      html << "<a href='/tr8n/phrases/index?section_key=#{key}'>" << section[:label] << "</a>"
      html << "<a href='" << section[:link] << "' target='_new'><img src='/tr8n/images/bullet_go.png' style='border:0px; vertical-align:middle'></a>" if section[:link]
      
      if section[:sections] and section[:sections].size > 0
        html << generate_sitemap(section[:sections], options)
      end  
      html << "</li>"
    end
    html << "</ul>"
  end
  
end
