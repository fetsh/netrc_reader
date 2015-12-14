require 'netrc_reader/version'

module NetrcReader
  class Config
    def initialize(path = nil)
      @path = netrc_file(path)
      @data = IO.readlines(@path)
    end

    alias_method :read, :new

    def self.machine_names
      @data.map { |l| l.match(/machine (.*) login.*/)[1] }
    end

    def self.[](name)
      Machine.new(name, config(name)) if machine_names.include?(name)
    end

    def self.netrc_file(path = nil)
      File.expand_path(path || File.join(ENV['NETRC'] || home_path, '.netrc'))
    end

    def self.home_path
      # if defined?(Smo3Data)
      #   Smo3Data::S3DConfig.options['home_path']
      # else
      Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
      # end
    end

    def config(name)
      @data.find { |l| l.match(/machine #{name} login.*/) }
    end
  end
  class Machine
    attr_reader :name

    def initialize(name, config)
      @name = name
      @config = config
    end

    alias_method :machine, :name

    def password
      creds.try { |md| md[:password] }
    end

    def login
      creds.try { |md| md[:login] }
    end

    def creds
      @config.match(
        /machine (?<machine>.*) login (?<login>.*) password (?<password>.*)$/
      )
    end
  end
end
