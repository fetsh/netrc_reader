class NetrcReader
  VERSION = '0.1.0'

  def initialize(path = nil)
    @path = netrc_file(path)
    @data = IO.readlines(@path)
  end

  def self.read(path = nil)
    new(path)
  end

  def machine_names
    @data.map { |l| l.match(/machine (.*) login.*/)[1] }
  end

  def [](name)
    Machine.new(name, config(name)) if machine_names.include?(name)
  end

  def find!(name)
    Machine.new(name, config!(name))
  end

  def netrc_file(path = nil)
    File.expand_path(path || File.join(ENV['NETRC'] || home_path, '.netrc'))
  end

  def home_path
    # if defined?(Smo3Data)
    #   Smo3Data::S3DConfig.options['home_path']
    # else
    Dir.respond_to?(:home) ? Dir.home : ENV['HOME']
    # end
  end

  def config(name)
    @data.find { |l| l.match(/machine #{name} login.*/) }
  end

  def config!(name)
    config(name) || fail(NetrcReader::Error, "#{name} was not found: #{@path}")
  end

  class Machine
    attr_reader :name

    def initialize(name, config)
      @name = name
      @config = config
    end

    alias_method :machine, :name

    def password
      creds[:password] if creds.respond_to?(:[])
    end

    def login
      creds[:login] if creds.respond_to?(:[])
    end

    def creds
      @config.match(
        /machine (?<machine>.*) login (?<login>.*) password (?<password>.*)$/
      )
    end
  end
end

NetrcReader::Error = Class.new(StandardError)
