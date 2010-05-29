require 'logger'

class Tr8n::Logger < Logger
  
  def self.logger
    return Rails.logger unless Tr8n::Config.config[:use_tr8n_logger]
    @logger ||= begin
      logfile_path = Tr8n::Config.config[:tr8n_log_path] if Tr8n::Config.config[:tr8n_log_path].first == '/' 
      logfile_path = "#{RAILS_ROOT}/#{Tr8n::Config.config[:tr8n_log_path]}" unless logfile_path
      logfile_dir = logfile_path.split("/")[0..-2].join("/")
      FileUtils.mkdir_p(logfile_dir) unless File.exist?(logfile_dir)
      logfile = File.open(logfile_path, 'a')
      logfile.sync = true
      Tr8n::Logger.new(logfile)
    end
  end
  
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)}: #{msg}\n" 
  end 
  
  def self.debug(msg)
    logger.debug(msg)
  end
  
  def self.info(msg)
    logger.info(msg)
  end

  def self.error(msg)
    logger.error(msg)
  end
  
  def self.fatal(msg)
    logger.fatal(msg)
  end
end 