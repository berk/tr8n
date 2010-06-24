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