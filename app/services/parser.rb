class Parser
  attr_accessor :lines
  SUCCESS = "1"
  FAIL = "0"
  def initialize(lines:)
    @lines = lines
  end

  def perform
    result = nil
    lines.each do |line|
      args = get_args(line)
      command = (args[0] + "_command").downcase.to_sym
      result = send(command, *args[1..])
    end
    result
  end

  private

  def get_args(line)
    line.squish.split(" ")
  end

  def set_command(key, value)
    Ledis.set(key: key, value: value)
  end

  def get_command(key)
    Ledis.get(key: key)
  end

  def keys_command
    result = ""
    Ledis.keys.each_with_index do |k, i|
        result += "#{i + 1}) #{k}<br>"
    end
    result[0..-5]
  end

  def del_command(key)
    Ledis.delete(key: key) ? SUCCESS : FAIL
  end

  def expire_command(key, time)
    Ledis.expire(key: key, time: time)
  end

  def ttl_command(key)
    Ledis.ttl(key: key)
  end
end