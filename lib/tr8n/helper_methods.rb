module Tr8n::HelperMethods
  include Tr8n::CommonMethods



  def tr8n_language_selector_tag
    render(:partial => '/tr8n/common/header_menu')    
  end
  
  def tr8n_footer_scripts_tag
    render(:partial => '/tr8n/common/footer_scripts')    
  end
  
  def tr8n_help_icon_tag(anchor = "top")
    link_to(image_tag("/tr8n/images/help.png", :style => "border:0px; vertical-align:middle;", :title => trl("Help")), {:controller => "/tr8n/help", :action => :index}, :anchor=> anchor, :target => "_new")
  end

  def tr8n_spinner_tag(id = "spinner", label = nil, cls='spinner')
    html = "<div id='#{id}' class='#{cls}' style='display:none'>"
    html << image_tag("/tr8n/images/spinner.gif")
    html << " #{trl(label)}" if label
    html << "</div>"
    html
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
    html
  end
  
  def generate_sitemap(sections, options = {})
    html = "<ul class='section_list'>"
    sections.each do |section|
      key = Tr8n::TranslationKey.generate_key(section[:label], section[:description])
      
      html << "<li class='section_list_item'>" 
      html << "<a href='/tr8n/translations/index?section_key=#{key}'>" << Tr8n::Language.translate(section[:label], section[:description]) << "</a>"
      html << "<a href='" << section[:link] << "' target='_new'><img src='/tr8n/images/bullet_go.png' style='border:0px; vertical-align:middle'></a>" if section[:link]
      
      if section[:sections] and section[:sections].size > 0
        html << generate_sitemap(section[:sections], options)
      end  
      html << "</li>"
    end
    html << "</ul>"
    html
  end

  def tr8n_user_tag(translator, options = {})
    return unless translator.user
    
    return "<a href='#{Tr8n::Config.user_link(translator.user)}'>#{Tr8n::Config.user_name(translator.user)}</a>" if options[:linked]
    Tr8n::Config.user_name(translator.user)
  end

  def tr8n_user_mugshot_tag(translator, options = {})
    return unless translator.user
    
    img_url = Tr8n::Config.user_mugshot(translator.user)
    return if img_url.blank?
    
    img_tag = "<img src='#{img_url}' style='width:48px'>"
    return "<a href='#{Tr8n::Config.user_link(translator.user)}'>#{img_tag}</a>" if options[:linked]
    img_tag
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
  
end
