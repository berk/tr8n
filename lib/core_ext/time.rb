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
    label.gsub!("%e", "{day_of_month}")

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
              :since_epoch          => strftime("%s"),
              :day_of_month         => strftime("%e"),
    }

#    options.merge!(:skip_decorations => true) if options[:skip_decorations].blank?
    language.tr(label, nil, tokens, options)
  end
  alias :tr :translate

  def trl(format = :default, language = Tr8n::Config.current_language, options = {})
    tr(format, language, options.merge!(:skip_decorations => true))
  end
end
