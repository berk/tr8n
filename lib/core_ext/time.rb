class Time

  def translate(language = Tr8n::Config.current_language, format = :default, options = {})
    label = (format.is_a?(String) ? format.clone : Tr8n::Config.default_date_formats[format].clone)
    label.gsub!("%a", "{short_week_day_name}")
    label.gsub!("%A", "{week_day_name}")
    label.gsub!("%b", "{short_month_name}")
    label.gsub!("%B", "{month_name}")
    label.gsub!("%p", "{am_pm}")
    label.gsub!("%d", "{days}")
    label.gsub!("%j", "{year_days}")
    label.gsub!("%m", "{months}")
    label.gsub!("%W", "{week_num}")
    label.gsub!("%w", "{week_days}")
    label.gsub!("%y", "{short_years}")
    label.gsub!("%Y", "{years}")
    label.gsub!("%H", "{full_hours}")
    label.gsub!("%I", "{short_hours}")
    label.gsub!("%M", "{minutes}")
    label.gsub!("%S", "{seconds}")

    tokens = {
              :days                 => (d.day < 10 ? "0#{d.day}" : d.day), 
              :year_days            => (d.yday < 10 ? "0#{d.yday}" : d.yday),
              :months               => (d.month < 10 ? "0#{d.month}" : d.month), 
              :week_num             => d.wday, 
              :week_days            => d.strftime("%w"), 
              :short_years          => d.strftime("%y"), 
              :years                => d.year,
              :short_week_day_name  => language.tr(Tr8n::Config.default_abbr_day_names[d.wday], "Short name for a day of a week", {}, options),
              :week_day_name        => language.tr(Tr8n::Config.default_day_names[d.wday], "Day of a week", {}, options),
              :short_month_name     => language.tr(Tr8n::Config.default_abbr_month_names[d.month - 1], "Short month name", {}, options),
              :month_name           => language.tr(Tr8n::Config.default_month_names[d.month - 1], "Month name", {}, options),
              :am_pm                => language.tr(d.strftime("%p"), "Meridian indicator", {}, options),
              :full_hours           => d.hour, 
              :short_hours          => d.strftime("%I"), 
              :minutes              => d.min, 
              :seconds              => d.sec              
    }

#    options.merge!(:skip_decorations => true) if options[:skip_decorations].blank?
    language.tr(label, nil, tokens, options)
  end
  alias :tr :translate
  
  def trl(format = :default, language = Tr8n::Config.current_language, options = {})
    tr(format, language, options.merge!(:skip_decorations => true))
  end
end
