class Time

  def with_leading_zero(num, options = {})
    return (num < 10 ? "0#{num}" : num) if options[:with_leading_zero]
    num
  end

  def tensify(past, present, future)
    current_time = Time.now
    return past if self < current_time
    return future if self > current_time
    present
  end

  def translate(format = :default, language = Tr8n::Config.current_language, options = {})
    label = (format.is_a?(String) ? format.clone : Tr8n::Config.default_date_formats[format].clone)
    label.gsub!("%a", "{short_week_day_name}")
    label.gsub!("%A", "{week_day_name}")
    label.gsub!("%b", "{short_month_name}")
    label.gsub!("%B", "{month_name}")
    label.gsub!("%p", "{am_pm}")
    label.gsub!("%d", "{days}")
    label.gsub!("%j", "{year_days}")
    label.gsub!("%l", "{trimed_hour}")
    label.gsub!("%m", "{months}")
    label.gsub!("%W", "{week_num}")
    label.gsub!("%w", "{week_days}")
    label.gsub!("%y", "{short_years}")
    label.gsub!("%Y", "{years}")
    label.gsub!("%H", "{full_hours}")
    label.gsub!("%I", "{short_hours}")
    label.gsub!("%M", "{minutes}")
    label.gsub!("%S", "{seconds}")
    label.gsub!("%s", "{since_epoch}")

    tokens = {
              :days                 => with_leading_zero(day, options),
              :year_days            => with_leading_zero(yday, options),
              :months               => with_leading_zero(month, options),
              :week_num             => wday,
              :week_days            => strftime("%w"),
              :short_years          => strftime("%y"),
              :years                => year,
              :short_week_day_name  => language.tr(Tr8n::Config.default_abbr_day_names[wday], "Short name for a day of a week", {}, options),
              :week_day_name        => language.tr(Tr8n::Config.default_day_names[wday], "Day of a week", {}, options),
              :short_month_name     => language.tr(Tr8n::Config.default_abbr_month_names[month - 1], "Short month name", {}, options),
              :month_name           => language.tr(Tr8n::Config.default_month_names[month - 1], "Month name", {}, options),
              :am_pm                => language.tr(strftime("%p"), "Meridian indicator", {}, options),
              :full_hours           => hour,
              :short_hours          => strftime("%I"),
              :trimed_hour          => strftime("%l"),
              :minutes              => strftime("%M"),
              :seconds              => strftime("%S"),
              :since_epoch          => strftime("%s")
    }

#    options.merge!(:skip_decorations => true) if options[:skip_decorations].blank?
    language.tr(label, nil, tokens, options)
  end
  alias :tr :translate

  def trl(format = :default, language = Tr8n::Config.current_language, options = {})
    tr(format, language, options.merge!(:skip_decorations => true))
  end
end
