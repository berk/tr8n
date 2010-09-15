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

class Tr8n::KeyLogger < Logger
  
  def self.logger
    return nil unless Tr8n::Config.enable_key_logger?
    @logger ||= begin
      logfile = File.open(logfile_path, 'a')
      logfile.sync = true
      Tr8n::KeyLogger.new(logfile)
    end
  end
  
  def self.logfile_path
    path = Tr8n::Config.config[:key_log_path] if Tr8n::Config.config[:key_log_path].first == '/' 
    path = "#{RAILS_ROOT}/#{Tr8n::Config.config[:key_log_path]}" unless path
    logfile_dir = path.split("/")[0..-2].join("/")
    FileUtils.mkdir_p(logfile_dir) unless File.exist?(logfile_dir)
    path
  end
  
  def format_message(severity, timestamp, progname, msg)
    "#{msg}\n" 
  end 
  
  def self.log(tkey)
    return unless logger
    logger.info(tkey.id.to_s)
  end
end 