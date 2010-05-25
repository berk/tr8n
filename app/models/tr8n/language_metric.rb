class Tr8n::LanguageMetric < ActiveRecord::Base
  set_table_name :tr8n_language_metrics

  belongs_to :language, :class_name => "Tr8n::Language"   

  def update_metrics!
    raise Exception.new("Must be implemented by the extending class")
  end
  
  def self.calculate_language_metrics
    last_daily_metric = Tr8n::DailyLanguageMetric.find(:first, :conditions => "metric_date is not null", :order => "metric_date desc")
    metric_date = last_daily_metric.nil? ? Date.new(2010, 5, 1) : last_daily_metric.metric_date

    Tr8n::Language.all.each do |lang|
      Tr8n::Config.logger.debug("Processing #{lang.english_name} language...")
      
      start_date = metric_date
      months=[]
      while start_date <= Date.today do
        Tr8n::Config.logger.debug("Generating daily data for #{start_date}...")
        
        months << Date.new(start_date.year, start_date.month, 1)
        lang.update_daily_metrics_for(start_date)
        start_date += 1.day
      end
      
      months.uniq.each do |month|
        Tr8n::Config.logger.debug("Generating monthly data for #{month}...")
        lang.update_monthly_metrics_for(month)
      end
      
      Tr8n::Config.logger.debug("Generating total data...")
      lang.update_total_metrics
    end    
  end
  
end
