require_relative 'dex-oracle/plugin'
require_relative 'dex-oracle/smali_file'

require 'logger'

class Oracle
  def initialize(smali_dir, driver)
    Dir["#{File.dirname(__FILE__)}/dex-oracle/plugins/*.rb"].each { |f| require f }
    Plugin.register_plugins
    @smali_files = Oracle.parse_smali(smali_dir)
    @logger = Logger.new(STDOUT)
    @driver = driver
  end

  def divine
    @smali_files.each do |smali_file|
      @logger.debug("Processing #{smali_file}")
      loop do
        Plugin.plugins.each { |p| p.process(@driver, smali_file) }
        smali_file.methods.each { |m| next if m.modified }
        break
      end
    end
  end

  private

  def self.parse_smali(smali_dir)
    smali_files = []
    Dir["#{smali_dir}/*.smali"].each { |f| smali_files << SmaliFile.new(f) }
    smali_files
  end
end