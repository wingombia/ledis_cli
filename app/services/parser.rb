class Parser
  attr_accessor :lines
  SUCCESS = "1"
  FAIL = "0"
  UPDATE = ["set", "sadd", "srem", "del", "expire"]
  RESPONSE_TYPES = {
    basic: [:set, :save, :restore],
    list: [:keys, :smembers, :sinter],
    bool: [:del, :expire],
    count: [:srem, :sadd],
    value: [:ttl, :get]
  }

  def initialize(lines:)
    @lines = Array(lines)
  end

  def perform(load: false)
    response = nil
    lines.each do |line|
      args = get_args(line)
      record(line.squish, args[0]) if !load
      command = (args[0] + "_command").downcase.to_sym
      #response = send(command, *args[1..])
      begin
        response = response(send(command, *args[1..]), args[0])
      rescue => e
        e = LedisExceptions::NoCommand.new if e.class == NoMethodError
        response = ResponseHandler.new(result: e, type: :error).perform
      end
    end
    response
  end

  private

  def get_args(line)
    line.squish.split(" ")
  end

  def set_command(key, value)
    Ledis.set(key: key.to_s, value: value)
  end

  def get_command(key)
    Ledis.get(key: key)
  end

  def keys_command
    Ledis.keys
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

  def sadd_command(key, *values)
    Ledis.sadd(key: key, values: values)
  end

  def srem_command(key, *values)
    Ledis.srem(key: key, values: values)
  end

  def smembers_command(key)
    Ledis.smembers(key: key)
  end

  def sinter_command(*keys)
    Ledis.sinter(keys: keys)
  end
  
  def save_command
    Ledis.save
  end

  def restore_command
    Ledis.restore
  end

  def record(line, command)
    if UPDATE.include?(command.downcase)
      Ledis.append_log(line: line)
    end
  end

  def response(result, command)
    ResponseHandler.new(result: result, type: type(command)).perform
  end

  def type(command)
    command_sym = command.downcase.to_sym
    RESPONSE_TYPES.each do |key, val|
      if val.include?(command_sym)
        return key 
      end
    end
  end


end