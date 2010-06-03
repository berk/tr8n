module Tr8n::HelperMethods
  include Tr8n::CommonMethods

  def tr8n_language_selector_tag
    render(:partial => '/tr8n/common/header_menu')    
  end
  
  def tr8n_footer_scripts_tag
    render(:partial => '/tr8n/common/footer_scripts')    
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
  
  def tr8n_help_icon_tag(anchor = "top")
    link_to(image_tag("/tr8n/images/help.png", :style => "border:0px; vertical-align:middle;", :title => trl("Help")), {:controller => "/tr8n/help", :action => :index}, :anchor=> anchor, :target => "_new")
  end

  def tr8n_spinner_tag(id = "spinner", label = nil, cls='spinner')
    html = "<div id='#{id}' class='#{cls}' style='display:none'>"
    html << image_tag("/tr8n/images/spinner.gif")
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
  
  def tr8n_footer_scripts_tag
    render(:partial => '/tr8n/common/footer_scripts')    
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
    render(:partial => "/model_filter/filter", :locals => {:model_filter => @model_filter})
  end

private

  def generate_sitemap(sections, options = {})
    html = "<ul class='section_list'>"
    sections.each do |section|
      key = Tr8n::TranslationKey.generate_key(section[:label], section[:description])
      
      html << "<li class='section_list_item'>" 
      html << "<a href='/tr8n/phrases/index?section_key=#{key}'>" << Tr8n::Language.translate(section[:label], section[:description]) << "</a>"
      html << "<a href='" << section[:link] << "' target='_new'><img src='/tr8n/images/bullet_go.png' style='border:0px; vertical-align:middle'></a>" if section[:link]
      
      if section[:sections] and section[:sections].size > 0
        html << generate_sitemap(section[:sections], options)
      end  
      html << "</li>"
    end
    html << "</ul>"
  end
  
end
