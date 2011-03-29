require 'csv'

def tr8n_db_path
  Rails.root.join("db/tr8n")
end

def tr8n_db_filename
  tr8n_db_path.join("tr8n.sql.gz")
end

def tr8n_source_filename
  tr8n_db_path.join("sources.json")
end

class CountryLang
  attr_accessor :country_name
  attr_accessor :language_names
  
  def initialize(country_name, language_names)
    self.country_name = country_name
    self.language_names = language_names
  end
end

namespace :tr8n do
  # Example usage of iso country mapping in application controller
  #   @country_code = Thread.current[:country_code] = (session[:country_code] ||= GeoIP.new(Rails.root.join("lib/geoip/GeoIP.dat")).country(request.remote_ip)[3]).downcase
  #   @iso_country = Tr8n::IsoCountry.find_by_code(@country_code.upcase)
  #   ...
  #   if @iso_country and not @iso_country.languages.empty?
  #     session[:locale] =  @iso_country.languages.first.locale
  #   else
  #     session[:locale] = tr8n_user_preffered_locale
  #   end

  desc "Import and setup iso 3166 countries"
  task :import_and_setup_iso_3166 => :environment do
    iso_countries = []
    country_languages = []
    CSV.parse(File.open(Rails.root.join("docs/geoip_iso_3166.csv"))) do |row|
      unless Tr8n::IsoCountry.find_by_code(row[0].strip)
        iso_countries << Tr8n::IsoCountry.create(:code=>row[0].strip, :country_english_name=>row[1].strip)
      else
        iso_countries << Tr8n::IsoCountry.find_by_code(row[0].strip)
      end
    end

    CSV.parse(File.open(Rails.root.join("docs/countries_lang.csv"))) do |row|
      country_languages << CountryLang.new(row[0].strip, row[1].strip) unless row[0]==""
    end
    
    puts iso_countries.inspect
    found = []
    errors = []
    country_languages.each do |language|
      best_guess_default_language_name = language.language_names.split(" ")[0].gsub(",","")
      language_lookup = Tr8n::Language.find(:first, :conditions => ['english_name LIKE ?', "%(#{language.country_name})%"])
      language_lookup = Tr8n::Language.find(:first, :conditions => ['english_name LIKE ?', "%#{best_guess_default_language_name}%"]) unless language_lookup
      if language.country_name=="Taiwan"
        language_lookup = Tr8n::Language.find(:first, :conditions => ['english_name LIKE ?', "%Chinese (Traditional)%"]) unless language_lookup
      end
      country_lookup = Tr8n::IsoCountry.find(:first, :conditions => ['country_english_name LIKE ?', "%#{language.country_name}%"])
      if language_lookup and country_lookup
        country_lookup.languages << language_lookup unless country_lookup.languages.exists?(language_lookup)
        found << "#{language.country_name} #{best_guess_default_language_name} > #{language_lookup.english_name} #{language_lookup.locale} > #{country_lookup.country_english_name} #{country_lookup.code}"
      else
        errors << "#{language.country_name} #{best_guess_default_language_name} ! #{language_lookup} #{country_lookup}"
      end
    end
    gb = Tr8n::IsoCountry.find_by_code("GB")
    gb.languages.delete_all
    gb.languages << Tr8n::Language.find_by_locale("en-UK")
    gb.save

    us = Tr8n::IsoCountry.find_by_code("US")
    us.languages.delete_all
    us.languages << Tr8n::Language.find_by_locale("en-US")
    us.save
    
    puts "Found #{found.count} countries"
    puts ""
    found.each do |x| puts x end

    puts "Did not find #{errors.count} countries"
    puts ""
    errors.each do |x| puts x end
 
    puts "No languages for:"    
    nocount = count = 0
    Tr8n::IsoCountry.all.each do |country|
      if country.languages.empty?
        puts country.inspect
        nocount += 1
      else
        count += 1
      end
    end
    puts "Languages for #{count} countries"
    puts "No languages for #{nocount} countries"
  end

  desc "Dump tr8n tables"
  task :dump_sources => :environment do
    sources = []
    Tr8n::TranslationSource.all.each do |translation_source|
      sources << translation_source.source unless translation_source.source.downcase.include?("tr8n")
    end
    puts "[#{sources.sort.map {|s| "\"#{s}\""}.join(",")}]"
  end

  desc "Dump tr8n tables"
  task :dump_db => :environment do
    config = Rails.application.config.database_configuration
    current_config = config[Rails.env]
    abort "db is not mysql" unless current_config['adapter'] =~ /mysql/
    
    database = current_config['database']
    user = current_config['username']
    password = current_config['password']

    tr8n_tables = ActiveRecord::Base.connection.tables.find_all {|t| t.include?("tr8n_") }.join(" ")
    FileUtils.mkdir_p(tr8n_db_path)
    command = "mysqldump --add-drop-table -u #{user} --password=#{password} #{database} #{tr8n_tables} | gzip > #{tr8n_db_filename}"
    puts "Excuting: #{command}"
    system command
  end

  desc "Import tr8n tables"
  task :import_db => :environment do
    config = Rails.application.config.database_configuration
    current_config = config[Rails.env]
    abort "db is not mysql" unless current_config['adapter'] =~ /mysql/
    
    database = current_config['database']
    user = current_config['username']
    password = current_config['password']

    tr8n_table = ActiveRecord::Base.connection.tables.find_all {|t| t.include?("tr8n_") }.join(" ")
    abort "TR8N import file does not exist" unless File.exists?(tr8n_db_filename)
    command = "gunzip < #{tr8n_db_filename} | mysql -u #{user} --password=#{password} #{database}"
    puts "Excuting: #{command}"
    system command
  end

  desc "Sync config and db migrations for tr8n plugin."
  task :sync do
    system "rsync -ruv vendor/plugins/tr8n/config/tr8n ./config"
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end

  desc "Sync db migrations for tr8n plugin."
  task :sync_db do
    system "rsync -ruv vendor/plugins/tr8n/db/migrate ./db"
  end

  desc "Initializes all of the tables with default data"
  task :init => :environment do
    raise "This action is prohibited in this environment" if ['production', 'stage', 'staging'].include?(Rails.env) and env('force') != 'true'
    Tr8n::Config.reset_all!
  end

  desc "Switches from manager flag to levels approach"
  task :upgrade_managers => :environment do
    # both of the following management approaches are deprecated, now use level only
    Tr8n::LanguageUser.find(:all, :conditions => "manager = true").each do |lu|
      next unless lu.translator
      lu.translator.update_attributes(:level => Tr8n::Config.manager_level)
    end
    Tr8n::Translator.connection.execute("update tr8n_translators set level = #{Tr8n::Config.manager_level} where manager = true")
  end

  desc "Adds missing languages from the yml file"
  task :import_languages => :environment do
    Tr8n::Config.default_languages.each do |locale, info|
      lang = Tr8n::Language.for(locale)
      next if lang

      info[:right_to_left] = false if info[:right_to_left].nil?
      info[:locale] = locale
      info[:enabled] = false
      lang = Tr8n::Language.create(info)

      lang.reset!
    end
  end

  desc "Updates languages with missing keys"
  task :update_language_keys => :environment do
    Tr8n::Config.default_languages.each do |locale, info|
      lang = Tr8n::Language.for(locale)
      next unless lang

      lang.google_key = info[:google_key]
      lang.facebook_key = info[:facebook_key]
      lang.save
    end
  end

  desc "Resets all metrics"
  task :reset_metrics => :environment do
    Tr8n::LanguageMetric.reset_metrics
  end

  desc "Calculates metrics"
  task :metrics => :environment do
    Tr8n::LanguageMetric.calculate_language_metrics
  end

  desc "Initializes default language cases"
  task :language_cases => :environment do
    Tr8n::Language.all.each do |lang|
      lang.reset_language_cases!
    end
  end

  desc "Creates featured languages"
  task :featured_languages => :environment do
    Tr8n::Config.config[:featured_languages].each_with_index do |locale, index|
      lang = Tr8n::Language.for(locale)
      lang.featured_index = 10000 - (index * 100)
      lang.save
    end
  end

  task :rtl_languages => :environment do
    File.open('rtllanguages.yml', 'w') do |f|
      Tr8n::Language.find(:all, :conditions => ["right_to_left = ?", true], :order => "english_name asc").each do |l|
        f.puts("\"#{l.locale}\":\n")
      end
    end
  end

  task :export_languages => :environment do
    File.open('languages.yml', 'w') do |f|
      Tr8n::Language.find(:all, :order => "english_name asc").each do |l|
        f.puts("\"#{l.locale}\":\n")
        f.puts("\tenglish_name: \"#{l.english_name}\"\n")
        f.puts("\tnative_name: \"#{l.native_name}\"\n")
        f.puts("\tgoogle_key: \"#{l.google_key}\"\n")
        f.puts("\tfacebook_key: \"#{l.facebook_key}\"\n")
      end
    end
  end

  task :configure_fallbacks => :environment do
    Tr8n::Language.all.each do |lang|
      locale = lang.locale
      next unless locale.index("-")
      fallback_locale = locale.split("-").first
      lang.fallback_language = Tr8n::Language.for(fallback_locale)
      lang.save
    end
  end

  # for old Geni languages only
  task :fix_languages => :environment do
    {"ay-BO"  => "ay",
    "en-CAN"  => "en-CA",
    "eo-EO"   => "eo",
    "fo-FO"   => "fo",
    "fr-CAN"  => "fr-CA",
    "gn-PY"   => "gn",
    "gu-IN"   => "gu",
    "iw"      => "he",
    "jv-ID"   => "jw",
    "kz"      => "kk",
    "kl"      => "tlh",
    "mg-MG"   => "mg",
    "mr-IN"   => "mr",
    "ps-AF"   => "ps",
    "qu-PE"   => "qu",
    "rm-CH"   => "rm",
    "sa-IN"   => "sa",
    "ta-IN"   => "ta",
    "xh-ZA"   => "xh",
    "zu-ZA"   => "zu"}.each do |old_locale, new_locale|
      lang = Tr8n::Language.for(old_locale)
      next unless lang
      lang.locale = new_locale
      lang.save

      # FOR GENI ONLY - REMOVE AFTER USE
      lang.language_users.each do |luser|
        next unless luser.user
        next unless luser.user.language == old_locale
        luser.user.language = new_locale
        luser.user.save
      end
    end
  end

  task :verify_keys => :environment do
    used_keys = {}

    # verification timestamp
    v_time = Time.now

    puts "Running verification process..."
    t0 = Time.now

    log_path = Tr8n::KeyLogger.logfile_path

    puts "Looking up log file at location..."
    puts "File path: #{log_path}"

    unless File.exists?(log_path)
      puts "Log file not found. Key logging process is not running."
      return
    end

    puts "Log file found. Renaming log file..."
    new_log_path = Tr8n::KeyLogger.switch_log(v_time)
    puts "Renamed file path: #{new_log_path}"

    puts "Scanning log file..."

    counter = 1
    file = File.new(new_log_path, "r")
    while (key_line = file.gets)
      key_id = key_line.strip
      used_keys[key_id] = true
      counter += 1

      puts "Scanned #{counter} lines..." if counter % 100 == 0
    end
    file.close
    t1 = Time.now
    puts "Scanned #{used_keys.keys.size} unique keys"
    puts "Scanning process took #{t1-t0} mls"

    puts "Marking keys as verified..."
    puts "There are #{Tr8n::TranslationKey.count} keys in the system"

    verify_count = 0
    used_keys.keys.each do |key|
      tkey = Tr8n::TranslationKey.find_by_id(key)
      next unless tkey
      tkey.verify!(v_time)
      verify_count += 1
    end

    t2 = Time.now
    puts "Verified #{verify_count} keys"
    puts "Verification process took #{t2-t1} mls"
  end

  # will delete all keys that have not been verified in the last 2 weeks
  task :delete_unverified_keys => :environment do
    date = env('before') || (Date.today - 2.weeks)

    puts "Running key destruction process..."
    t0 = Time.now

    puts "All keys not verified after #{date} will be destroyed!"
    unverified_keys = Tr8n::TranslationKey.find(:all, :conditions => ["verified_at is null or verified_at < ?", date])

    puts "There are #{unverified_keys.size} keys to be destroyed."
    puts "Destroying unverified keys..." if unverified_keys.size > 0

    destroy_count = 0
    unverified_keys.each do |tkey|
      tkey.destroy
      destroy_count += 1
      puts "Destroyed #{destroy_count} keys..." if destroy_count % 100 == 0
    end

    t1 = Time.now

    puts "Destroyed #{destroy_count} keys"
    puts "Destruction process took #{t1-t0} mls"
  end

  desc 'Update IP to Location table (file=<file|config/tr8n/data/ip_locations.csv>)'
  task :import_ip_locations => :environment do
    Tr8n::IpLocation.import_from_file('config/tr8n/data/ip_locations.csv', :verbose => true)
  end

end

