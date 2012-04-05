# https://developers.google.com/closure/compiler/
# http://developer.yahoo.com/yui/compressor

require 'pp'
require 'yaml'
require 'fssm'

pp "Started monitoring ./src folder. To stop use Ctrl+C."

FSSM.monitor('./src/', '**/*') do
  update do |base, relative|
    pp "#{relative} file changed"
    compile
  end

  delete do |base, relative|
    pp "#{relative} deleted"
    compile
  end

  create do |base, relative|
    pp "#{relative} created"
    compile
  end

  def config
    @config ||= YAML.load_file("config.yml")
  end

  def compile
    command = "java -jar compressors/google/compiler.jar --js #{config['all']} --js_output_file ../assets/javascripts/tr8n/tr8n-compiled.js; echo 'Done'"
    pp command
    Kernel.spawn(command)
  end

end

