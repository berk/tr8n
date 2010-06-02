class Tr8n::LanguageMetric < ActiveRecord::Base
  set_table_name :tr8n_language_metrics

  belongs_to :language, :class_name => "Tr8n::Language"   

  def self.default_attributes
    {:user_count => 0, :translator_count => 0, 
     :translation_count => 0, :key_count => 0, 
     :locked_key_count => 0, :translated_key_count => 0}
  end
  
  def default_attributes
    self.class.default_attributes  
  end

  def update_metrics!
    raise Exception.new("Must be implemented by the extending class")
  end
  
  def self.reset_metrics
    delete_all
    calculate_language_metrics
  end
  
  def self.calculate_language_metrics
    last_daily_metric = Tr8n::DailyLanguageMetric.find(:first, :conditions => "metric_date is not null", :order => "metric_date desc")
    metric_date = last_daily_metric.nil? ? Date.new(2010, 5, 1) : last_daily_metric.metric_date

    Tr8n::Language.all.each do |lang|
      Tr8n::Logger.debug("Processing #{lang.english_name} language...")
      
      start_date = metric_date
      months=[]
      while start_date <= Date.today do
        Tr8n::Logger.debug("Generating daily data for #{lang.english_name} language on #{start_date}...")
        
        months << Date.new(start_date.year, start_date.month, 1)
        lang.update_daily_metrics_for(start_date)
        start_date += 1.day
      end
      
      months.uniq.each do |month|
        Tr8n::Logger.debug("Generating monthly data for #{lang.english_name} language on #{month}...")
        lang.update_monthly_metrics_for(month)
      end
      
      Tr8n::Logger.debug("Generating total data for #{lang.english_name} language...")
      lang.update_total_metrics
    end    
  end
  
  def not_translated_count
    return key_count unless translated_key_count
    key_count - translated_key_count    
  end
  
  def pending_approval_count
    return translated_key_count unless locked_key_count
    translated_key_count - locked_key_count
  end
end
