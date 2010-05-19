require 'logger'

class Tr8n::Logger < Logger
  
  def format_message(severity, timestamp, progname, msg)
    "#{timestamp.to_formatted_s(:db)}: #{msg}\n" 
  end 
  
end 