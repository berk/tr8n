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

class Wf::Calendar

  MONTHS = ['January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December']
  DAYS = ['sun', 'mon', 'tue', 'wed', 'thu', 'fri', 'sat']
  
  def initialize(selected_date = nil, start_date = nil, show_time = false, mode = 'month')
    if selected_date.blank?
      @selected_date = Time.now 
    else
      begin 
        @selected_date = Time.parse(selected_date)
      rescue
        @selected_date = Time.now 
      end
    end
    
    if start_date.is_a?(Date)
      @start_date = start_date
    else  
      @start_date = start_date.blank? ? Date.new(@selected_date.year, @selected_date.month, 1) : Date.parse(start_date)
    end
    
    @show_time = show_time
    @mode = mode
  end
  
  def mode
    @mode ||= 'month'
  end
  
  def selected_date
    @selected_date ||= Time.now
  end
  
  def month 
    start_date.month
  end

  def year 
    start_date.year
  end

  def hour 
    selected_date.hour
  end

  def minute 
    selected_date.min
  end

  def second 
    selected_date.sec
  end

  def start_date
    @start_date ||= Date.new(Date.today.year, Date.today.month, 1)
  end
  
  def end_date
    @end_date ||= Date.new(start_date.year, start_date.month, days_in_month) 
  end
  
  def days_in_month
    @days_in_month ||= (Date.new(year, 12, 31).to_date<<(12 - month)).day
  end
  
  def show_time?
    @show_time
  end
  
  def move(delta)
    return self if delta.blank? or delta == 0
    Wf::Calendar.new(selected_date, start_date + delta, show_time?, mode)
  end
  
  def title
    "#{MONTHS[month-1]}, #{year}"
  end
  
  def next_start_date
    return start_date + 1.year if mode == 'annual'
    start_date + 1.month
  end
  
  def previous_start_date
    return start_date - 1.year if mode == 'annual'
    start_date - 1.month
  end
  
  
  def self.year_options
    @year_options ||= begin
      yo = []
      (Date.today.year - 100).upto(Date.today.year + 30) do |year|
        yo << [year, year]
      end
      yo
    end
  end

  def self.month_options
    @month_options ||= begin
      mo = []
      MONTHS.each_with_index do |m, i|
        mo << [m, i+1]
      end
      mo
    end    
  end

  def self.days
    DAYS
  end
  
  def self.hour_options
    @hour_options ||= begin
      ho = []
      0.upto(23) do |i| 
        ho << [prepand_zero(i), i]
      end  
      ho
    end
  end
  
  def self.minute_options
    @minute_options ||= begin
      mo = []
      0.upto(59) do |i| 
        mo << [prepand_zero(i), i] 
      end
      mo
    end      
  end

  def self.second_options
    @second_options ||= minute_options
  end
  
  def self.prepand_zero(num)
    (num < 10 ? "0#{num}" : "#{num}")
  end
  
end