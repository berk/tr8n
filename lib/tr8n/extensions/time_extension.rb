#--
# Copyright (c) 2010-2012 Michael Berkovich, tr8n.net
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
    symbols = label.scan(/(%\w)/).flatten.uniq

    selected_tokens = []
    symbols.each do |symbol|
      token = Tr8n::Config.strftime_symbol_to_token(symbol)
      next unless token
      selected_tokens << token
      label.gsub!(symbol, token)
    end

    tokens = {}
    selected_tokens.each do |token|
      case token
        when "{days}" then tokens[:days] = with_leading_zero(day, options)
        when "{year_days}" then tokens[:year_days] = with_leading_zero(yday, options)
        when "{months}" then tokens[:months] = with_leading_zero(month, options)
        when "{week_num}" then tokens[:week_num] = wday
        when "{week_days}" then tokens[:week_days] = strftime("%w")
        when "{short_years}" then tokens[:short_years] = strftime("%y")
        when "{years}" then tokens[:years] = year
        when "{short_week_day_name}" then tokens[:short_week_day_name] = language.tr(Tr8n::Config.default_abbr_day_names[wday], "Short name for a day of a week", {}, options)
        when "{week_day_name}" then tokens[:week_day_name] = language.tr(Tr8n::Config.default_day_names[wday], "Day of a week", {}, options)
        when "{short_month_name}" then tokens[:short_month_name] = language.tr(Tr8n::Config.default_abbr_month_names[month - 1], "Short month name", {}, options)
        when "{month_name}" then tokens[:month_name] = language.tr(Tr8n::Config.default_month_names[month - 1], "Month name", {}, options)
        when "{am_pm}" then tokens[:am_pm] = language.tr(strftime("%p"), "Meridian indicator", {}, options)
        when "{full_hours}" then tokens[:full_hours] = hour
        when "{short_hours}" then tokens[:short_hours] = strftime("%I")
        when "{trimed_hour}" then tokens[:trimed_hour] = strftime("%l")
        when "{minutes}" then tokens[:minutes] = strftime("%M")
        when "{seconds}" then tokens[:seconds] = strftime("%S")
        when "{since_epoch}" then tokens[:since_epoch] = strftime("%s")
        when "{day_of_month}" then tokens[:day_of_month] = strftime("%e")
      end
    end
  
    language.tr(label, nil, tokens, options)
  end
  alias :tr :translate

  def trl(format = :default, language = Tr8n::Config.current_language, options = {})
    tr(format, language, options.merge!(:skip_decorations => true))
  end
end
