require 'socket'

#  FluentD tail replacer that adds source, ip address, and optionally injects and
#  formats the timestamp based on another field in a different format (adding
#  the current year if requested to) to ISO 8061.
#  Inspired by http://docs.fluentd.org/articles/plugin-development#customizing-the-tail-input-plugin-parser

class TailInputExtender < Fluent::TailInput
  Fluent::Plugin.register_input('tailExtender', self)

  config_param :source, :string
  config_param :log_time_key, :string, :default => nil
  config_param :log_time_format, :string, :default => nil
  config_param :inject_year, :string, :default => nil

  def configure(conf)
    super
    #  OK if we don't mess around with the timestamp at all - it could already
    #  be in the correct field in the correct format
    if (@log_time_key && !@log_time_format) ||
      (!@log_time_key && @log_time_format)
      raise Fluent::ConfigError, "log_time_format parameter(#{@log_time_format}) and log_time_key(#{@log_time_key}) must be both present or both missing"
    end

    @ip_address = IPSocket.getaddress(Socket.gethostname)
  end

  def parse_line(line)
    time, record = super

    record['source'] = @source

    if record[@log_time_key]
      time_str = record[@log_time_key]
      time_str = Time.now().year.to_s() + time_str if @inject_year == 'Y'
      timestamp = Time.strptime(time_str, @log_time_format)
      record['timestamp'] = timestamp.strftime('%Y-%m-%dT%H:%M:%SZ')
    end

    record['ip_address'] = @ip_address

    return time, record
  end
end

#  Extend the in_tail_multiline plugin to require injection of the data source
#  into the record, from the configuration source param.
require 'fluent/plugin/in_tail_multiline'

class TailMultilineInputExtender < Fluent::TailMultilineInput
  Fluent::Plugin.register_input('tailMultilineExtender', self)

  config_param :source, :string

  def configure(conf)
    super
    @ip_address = IPSocket.getaddress(Socket.gethostname)
  end

  def parse_logbuf(buf)
    time, record = super
    if record
      record['source'] = @source
      record['ip_address'] = @ip_address
    end
    return time, record
  end
end
