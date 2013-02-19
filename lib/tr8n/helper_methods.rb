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

module Tr8n::HelperMethods
  include Tr8n::CommonMethods

  def tr8n_scripts_tag(opts = {})
    render(:partial => '/tr8n/common/scripts', :locals => {:opts => opts})    
  end

  def tr8n_default_client_source
    "#{params[:controller]}/#{params[:action]}/JS"
  end

  # Creates a hash of translations for a page source(s) or a component(s)
  def tr8n_translations_cache_tag(opts = {})
    html = []

    opts[:translations_element_id] ||= :tr8n_translations
    opts[:sources] ||= [tr8n_default_client_source]
    client_sdk_var_name = opts[:client_var_name] || :tr8nProxy

    if Tr8n::Config.enable_browser_cache?  # translations are loaded through a script

      opts[:sources].each do |source_name|
        source = Tr8n::TranslationSource.find_or_create(source_name, request.url)
        js_source = "/tr8n/api/v1/language/translate.js?cache=true&sdk_jsvar=#{client_sdk_var_name}&source=#{CGI.escape(source_name)}&t=#{source.updated_at.to_i}"
        html << "<script type='text/javascript' src='#{js_source}'></script>"
      end  

    else  # translations are embedded right into the page

      html << "<script>"
      sources = Tr8n::TranslationSource.find(:all, :conditions => ["source in (?)", opts[:sources]])
      source_ids = sources.collect{|source| source.id}

      if source_ids.empty?
        conditions = ["1=2"]
      else
        conditions = ["(id in (select distinct(translation_key_id) from tr8n_translation_key_sources where translation_source_id in (?)))"]
        conditions << source_ids.uniq
      end

      translations = []
      Tr8n::TranslationKey.find(:all, :conditions => conditions).each_with_index do |tkey, index|
        trn = tkey.translate(Tr8n::Config.current_language, {}, {:api => true})
        translations << trn 
      end

      html << "#{client_sdk_var_name}.updateTranslations(#{translations.to_json});"
      html << "</script>"
    end
      
    html.join('')
  end

  # Creates an instance of tr8nProxy object
  def tr8n_client_sdk_tag(opts = {})
    opts[:default_source]           ||= tr8n_default_client_source
    opts[:scheduler_interval]       ||= Tr8n::Config.default_client_interval

    opts[:enable_inline_translations] = (Tr8n::Config.current_user_is_translator? and Tr8n::Config.current_translator.enable_inline_translations? and (not Tr8n::Config.current_language.default?))
    opts[:default_decorations]        = Tr8n::Config.default_decoration_tokens
    opts[:default_tokens]             = Tr8n::Config.default_data_tokens

    opts[:rules]                      = { 
      :number => Tr8n::Config.rules_engine[:numeric_rule],      :gender => Tr8n::Config.rules_engine[:gender_rule],
      :list   => Tr8n::Config.rules_engine[:gender_list_rule],  :date   => Tr8n::Config.rules_engine[:date_rule]
    }

    client_var_name = opts[:client_var_name] || :tr8nProxy

    html = []
    html << "<script>"
    html << "  var #{client_var_name} = new Tr8n.Proxy(#{opts.to_json});"
    html << "  function reloadTranslations() { "
    html << "    #{client_var_name}.initTranslations(true); "
    html << "  } "
    html << "  function tr(label, description, tokens, options) { "
    html << "    return #{client_var_name}.tr(label, description, tokens, options); "
    html << "  } "
    html << "  function trl(label, description, tokens, options) { "
    html << "    return #{client_var_name}.trl(label, description, tokens, options); "
    html << "  } "

    if Tr8n::Config.enable_tml?
      html << "  Tr8n.Utils.addEvent(window, 'load', function() { "
      html << "    #{client_var_name}.initTml(); "                               
      html << "  }) "                              
    end

    html << "</script>"
    html.join("\n").html_safe
  end
        
  def tr8n_options_for_select(options, selected = nil, description = nil, lang = Tr8n::Config.current_language)
    options_for_select(options.tro(description), selected)
  end

  def tr8n_phrases_link_tag(search = "", phrase_type = :without, phrase_status = :any)
    return unless Tr8n::Config.enabled?
    return if Tr8n::Config.current_language.default?
    return unless Tr8n::Config.current_user_is_translator?
    return unless Tr8n::Config.current_translator.enable_inline_translations?
    
    link_to(image_tag("/tr8n/images/translate_icn.gif", :style => "vertical-align:middle; border: 0px;", :title => search), 
           :controller => "/tr8n/phrases", :action => :index, 
           :search => search, :phrase_type => phrase_type, :phrase_status => phrase_status)
  end

  def tr8n_style_attribute_tag(attr_name = 'float', default = 'right', lang = Tr8n::Config.current_language)
    "#{attr_name}:#{lang.align(default)}"
  end

  def tr8n_style_directional_attribute_tag(attr_name = 'padding', default = 'right', value = '5px', lang = Tr8n::Config.current_language)
    "#{attr_name}-#{lang.align(default)}:#{value}"
  end

  def tr8n_dir_attribute_tag(lang = Tr8n::Config.current_language)
    "dir='#{lang.dir}'"
  end

  def tr8n_splash_screen_tag
    html = "<div id='tr8n_splash_screen' style='display:none'>"
    html << (render :partial => Tr8n::Config.splash_screen)
    html << "</div>"
  end

  def tr8n_language_flag_tag(lang = Tr8n::Config.current_language, opts = {})
    return "" unless Tr8n::Config.enable_language_flags?
    html = image_tag("/tr8n/images/flags/#{lang.flag}.png", :style => "vertical-align:middle;", :title => lang.native_name)
    html << "&nbsp;" 
  end

  def tr8n_language_name_tag(lang = Tr8n::Config.current_language, opts = {})
    show_flag = opts[:flag].nil? ? true : opts[:flag]
    name_type = opts[:name].nil? ? :full : opts[:name] # :full, :native, :english, :locale
    linked = opts[:linked].nil? ? true : opts[:linked] 
    
    html = "<span style='white-space: nowrap'>"
    html << tr8n_language_flag_tag(lang, opts) if show_flag
    html << "<span dir='ltr'>"
    
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
    
    html << "</span></span>"
  end

  def tr8n_language_selector_tag(opts = {})
    opts[:lightbox] ||= false
    opts[:style] ||= "color:#1166bb;"
    opts[:show_arrow] ||= true
    opts[:arrow_style] ||= "font-size:8px;"
    render(:partial => '/tr8n/common/language_selector', :locals => {:opts => opts})    
  end

  def tr8n_language_strip_tag(opts = {})
    opts[:flag] = opts[:flag].nil? ? false : opts[:flag]
    opts[:name] = opts[:name].nil? ? :native : opts[:name] 
    opts[:linked] = opts[:linked].nil? ? true : opts[:linked] 
    opts[:javascript] = opts[:javascript].nil? ? false : opts[:javascript] 
    
    render(:partial => '/tr8n/common/language_strip', :locals => {:opts => opts})    
  end

  def tr8n_language_table_tag(opts = {})
    opts[:cols] = opts[:cols].nil? ? 4 : opts[:cols]
    opts[:col_size] = opts[:col_size].nil? ? "300px" : opts[:col_size]
    render(:partial => '/tr8n/common/language_table', :locals => {:opts => opts.merge(:name => :english)})    
  end

  def tr8n_translator_login_tag(opts = {})
    opts[:class] ||= 'tr8n_right_horiz_list'
    render(:partial => '/tr8n/common/translator_login', :locals => {:opts => opts})    
  end

  def tr8n_flashes_tag(opts = {})
    render(:partial => '/tr8n/common/flashes', :locals => {:opts => opts})    
  end

  def tr8n_translator_rank_tag(translator, rank = nil)
    return "" unless translator
    
    rank ||= translator.rank || 0
    
    html = "<span dir='ltr'>"
    1.upto(5) do |i|
      if rank > i * 20 - 10  and rank < i * 20  
        html << image_tag("/tr8n/images/rating_star05.png")
      elsif rank < i * 20 - 10 
        html << image_tag("/tr8n/images/rating_star0.png")
      else
        html << image_tag("/tr8n/images/rating_star1.png")
      end 
    end
    html << "</span>"
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
    html << link_to_function("#{image_tag("/tr8n/images/arrow_down.gif", :style=>'text-align:center; vertical-align:middle')} #{label}", "Tr8n.Effects.hide('#{content_id}_open'); Tr8n.Effects.show('#{content_id}_closed'); Tr8n.Effects.blindUp('#{content_id}');", :style=> "text-decoration:none")
    html << "</span>" 
    html << "<span id='#{content_id}_closed' "
    html << "style='display:none'" if open
    html << ">"
    html << link_to_function("#{image_tag("/tr8n/images/arrow_right.gif", :style=>'text-align:center; vertical-align:middle')} #{label}", "Tr8n.Effects.show('#{content_id}_open'); Tr8n.Effects.hide('#{content_id}_closed'); Tr8n.Effects.blindDown('#{content_id}');", :style=> "text-decoration:none")
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
  
  def tr8n_breadcrumb_tag(source = nil, opts = {})
    source ||= "#{controller.class.name.underscore.gsub("_controller", "")}/#{controller.action_name}" 
    section = Tr8n::SiteMap.section_for_source(source)
    return "" unless section
    opts[:separator] ||= " >> "
    opts[:min_elements] ||= 1
    opts[:skip_root] ||= opts[:skip_root].nil? ? false : opts[:skip_root]

    links = section.parents.collect{|node| link_to(node.title(params), node.link(params))}
    return "" if links.size <= opts[:min_elements]
    
    links.delete(links.first) if opts[:skip_root]
    links.unshift(link_to(opts[:root].first, opts[:root].last)) if opts[:root]
    
    html = "<div id='tr8n_breadcrumb' class='tr8n_breadcrumb'>"
    html << links.join(opts[:separator])
    html << '</div>'    
  end
  
  def tr8n_user_tag(translator, options = {})
    return "Deleted Translator" unless translator
    
    if options[:linked]
      link_to(translator.name, translator.link)
    else
      translator.name
    end
  end

  def tr8n_user_mugshot_tag(translator, options = {})
    if translator and !translator.mugshot.blank?
      img_url = translator.mugshot
    else
      img_url = Tr8n::Config.silhouette_image
    end
    
    img_tag = "<img src='#{img_url}' style='width:48px'>"
    
    if translator and options[:linked]
      link_to(img_tag, translator.link)
    else  
      img_tag
    end
  end  
  
  def tr8n_will_paginate(collection = nil, options = {})
    will_paginate(collection, options.merge(:previous_label => tr("{laquo} Previous", "Previous entries in a list", {}, options), 
                                            :next_label => tr("Next {raquo}", "Next entries in a list", {}, options)))
  end

  def tr8n_page_entries_info(collection, options = {})
    entry_name = options[:entry_name] || (collection.empty? ? 'entry' : collection.first.class.name.underscore.sub('_', ' '))
    
    if collection.total_pages < 2
      case collection.size
        when 0
          tr("None found", "Paginator no entries message", {}, options)
        when 1
          tr("Displaying [strong: 1] #{entry_name}", "Paginator one page message", {}, options)
        else
          tr("Displaying [strong: all {count}] #{entry_name.pluralize}", "Paginator all entries message", {:count => collection.size}, options)
      end
    else
      tr("Displaying #{entry_name.pluralize} [strong: {start_num} - {end_num}] of [strong: {total_count}] in total", 
         "Paginator custom message", {
            :start_num    => collection.offset + 1,
            :end_num      => collection.offset + collection.length,
            :total_count  => collection.total_entries
         }, options
      )
    end
  end

  def tr8n_select_month(date, options = {}, html_options = {})
    month_names = options[:use_short_month] ? Tr8n::Config.default_abbr_month_names : Tr8n::Config.default_month_names
    select_month(date, options.merge(
      :use_month_names => month_names.collect{|month_name| Tr8n::Language.translate(month_name, options[:description] || "Month name")} 
    ), html_options)
  end

  def tr8n_content_for_locales_tag(opts = {})
    locale = Tr8n::Config.current_language.locale

    if opts[:only] 
       return unless opts[:only].include?(locale)
    end

    if opts[:except]
      return if opts[:except].include?(locale)
    end

    if block_given?
      ret = yield
    end
    ret
  end

  def tr8n_content_for_countries_tag(opts = {})
    country = Tr8n::Config.country_from_ip(tr8n_request_remote_ip)
    
    if opts[:only] 
       return unless opts[:only].include?(country)
    end

    if opts[:except]
      return if opts[:except].include?(country)
    end

    if block_given?
      ret = yield
    end
    ret
  end

  def tr8n_language_completeness_chart_tag(language = Tr8n::Config.current_language)
    values = [language.total_metric.not_translated_count, language.total_metric.locked_key_count, language.total_metric.translated_key_count - language.total_metric.locked_key_count]
    names = [trl("Not Translated"), trl("Approved"), trl("Pending Approval")]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end
  
  def tr8n_translator_rank_chart_tag(language = nil)
    metric = language ? tr8n_current_translator.metric_for(language) : tr8n_current_translator.total_metric
    values = [metric.rejected_translations, metric.accepted_translations, metric.pending_vote_translations]
    names = [trl("Rejected"), trl("Accepted"), trl("Pending Votes")]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end  

  def tr8n_translation_source_completeness_chart_tag(metric = nil)
    values = [metric.not_translated_count, metric.locked_key_count, metric.translated_key_count - metric.locked_key_count]
    names = [trl("Not Translated"), trl("Approved"), trl("Pending Approval")]
    colors = ['FF0000', '00FF00', 'FFFF00']
    chart_url = "https://chart.googleapis.com/chart?cht=p3&chs=350x80&chd=t:#{values.join(',')}&chl=#{names.join('|')}&chco=#{colors.join('|')}"
    image_tag(chart_url)
  end  

  def tr8n_when_string_tag(time, opts = {})
    elapsed_seconds = Time.now - time
    if elapsed_seconds < 0
      tr('In the future, Marty!', 'Time reference')
    elsif elapsed_seconds < 2.minutes
      tr('a moment ago', 'Time reference')
    elsif elapsed_seconds < 55.minutes
      elapsed_minutes = (elapsed_seconds / 1.minute).to_i
      tr("{minutes||minute} ago", 'Time reference', :minutes => elapsed_minutes)
    elsif elapsed_seconds < 1.75.hours
      tr("about an hour ago", 'Time reference')
    elsif elapsed_seconds < 12.hours
      elapsed_hours = (elapsed_seconds / 1.hour).to_i
      tr("{hours||hour} ago", 'Time reference', :hours => elapsed_hours)
    elsif time.today_in_time_zone?
      display_time(time, :time_am_pm)
    elsif time.yesterday_in_time_zone?
      tr("Yesterday at {time}", 'Time reference', :time => time.tr(:time_am_pm).gsub('/ ', '/').sub(/^[0:]*/,""))
    elsif elapsed_seconds < 5.days
      time.tr(:day_time).gsub('/ ', '/').sub(/^[0:]*/,"")
    elsif time.same_year_in_time_zone?
      time.tr(:monthname_abbr_time).gsub('/ ', '/').sub(/^[0:]*/,"")
    else
      time.tr(:monthname_abbr_year_time).gsub('/ ', '/').sub(/^[0:]*/,"")
    end
  end

private

  def generate_sitemap(sections, options = {})
    html = "<ul class='section_list'>"
    sections.each do |section|
      html << "<li class='section_list_item'>" 
      html << "<a href='/tr8n/phrases/index?section_key=#{section.key}'>" << tr(section.label, section.description) << "</a>"
      html << "<a href='" << section.data[:link] << "' target='_new'><img src='/tr8n/images/bullet_go.png' style='border:0px; vertical-align:middle'></a>" if section.data[:link]
      
      if section.children.size > 0
        html << generate_sitemap(section.children, options)
      end  
      html << "</li>"
    end
    html << "</ul>"
  end
  
end
