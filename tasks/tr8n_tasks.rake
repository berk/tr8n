namespace :tr8n do
  desc "Sync extra files from tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config ."
    system "rsync -ruv vendor/plugins/tr8n/db/migrate db"
    system "rsync -ruv vendor/plugins/tr8n/public ."
  end
  
  desc "Initializes all of the tables with default data"
  task :init => :environment do
    Tr8n::Config.reset_all!
  end
  
  task :update_languages => :environment do
    {"am" => "hy", "gs" => "ka", "eu_ES" => "eu", "ur_PK" => "ur"}. each do |old, new|
      lang = Tr8n::Language.for(old)
      next unless lang
      lang.update_attributes(:locale => new)
    end
    Tr8n::Language.all.each do |lang|
      next unless lang.locale.index("_")
      lang.update_attributes(:locale => lang.locale.gsub("_", "-"))
    end
  end
  
  task :clean_icons => :environment do
    Tr8n::Language.all.each do |lang|
      FileUtils.cp("#{RAILS_ROOT}/public/images/tr8n/flags/#{lang.flag}.png", "#{RAILS_ROOT}/public/images/tr8n/flags/used/#{lang.flag}.png")
    end
  end

  task :update_language_metrics => :environment do
    Tr8n::LanguageMetric.calculate_language_metrics
  end
  
end