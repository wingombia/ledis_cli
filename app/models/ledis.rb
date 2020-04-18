module Ledis
  LOG_FILE = Rails.root.join("log.txt")
  DUMP_FILE = Rails.root.join("dump.txt")
  @@storage = {}
  ###STRING###

  def self.set(key:, value:)
    @@storage[key] = remove_dq(value)
    "OK"
  end

  def self.get(key:)
    check_type(key, String)
    touch(key: key)
  end
  
  ###DATA_EXPIRATION###

  def self.keys
    result = []
    @@storage.keys.each do |key|
      result << key if touch(key: key)
    end
    result
  end

  def self.delete(key:)
    @@storage.delete(key)
  end

  def self.expire(key:, time:)
    exist?(key) ? set_expire(key, Time.now.sec + time.to_i) : nil
  end

  def self.ttl(key:)
    touch(key: key)
    return -2 if !exist?(key)
    return -1 if get_expire(key) == -1
    get_expire(key) - Time.now.sec
  end

  ###SET###

  def self.sadd(key:, values:)
    #TODO: Implement WRONG TYPE ERROR
    key_val = touch(key: key)
    if !(check_type(key, Set))
      @@storage[key] = Set.new
      key_val = @@storage[key]
    end
    count = 0

    Array(values).each do |val|
      val = remove_dq(val)
      count += 1 if key_val.add?(val) 
    end
    count
  end

  def self.srem(key:, values:)
    return 0 if !(check_type(key, Set))
    key_val = touch(key: key)
    count = 0

    Array(values).each do |val|
      val = remove_dq(val)
      count += 1 if key_val.delete?(val)
    end
    count
  end

  def self.smembers(key:)
    return "" if !(check_type(key, Set))
    key_val = touch(key: key)
    key_val
  end

  def self.sinter(keys:)
    result = nil
    keys.each do |key|
      check_type(key, Set)
      set = Set.new(touch(key: key))
      result = !result ? set : result & set
    end
    result
  end

  def self.storage
    @@storage
  end
  
  def self.touch(key:)
    if exist?(key) && expired?(key)
      append_log(line: "del #{key}")
      delete(key: key)
      return false
    end
    value(key)
  end

  ###FILE###
  def self.check_type(key, type)
    tmp = key_type(key)
    raise LedisExceptions::WrongType.new if tmp != type && tmp != NilClass
    (tmp == NilClass) ? false : true
  end

  def self.append_log(line:)
    File.new(LOG_FILE, "w") if !LOG_FILE.exist?
    File.open(LOG_FILE, "a") { |f| f.write(line + "\n") }
  end

  def self.load(file_path: LOG_FILE)
    File.open(file_path) do |f|
      lines = f.readlines.map(&:chomp)
      Parser.new(lines: lines).perform(load: true)
    end
  end
  
  def self.save(file_path: DUMP_FILE)
    File.new(LOG_FILE, "w") if !LOG_FILE.exist?
    FileUtils.cp(LOG_FILE, file_path)
  end

  def self.restore(file_path: DUMP_FILE)
    return "(no dump file)" if !DUMP_FILE.exist?
    @@storage = {}
    FileUtils.cp(file_path, LOG_FILE)
    load
  end

  private

  def self.key_type(key)
    value(key).class
  end

  def self.remove_dq(value)
    if value[0] == '"'
      value = value[1..-2]
    end
    value
  end

  def self.expired?(key)
    return false if !have_expire?(key)
    expire = get_expire(key)   
    expire <= Time.now.sec
  end

  def self.exist?(key)
    @@storage[key]
  end

  def self.value(key)
   have_expire?(key) ? @@storage[key][:value] : @@storage[key]
  end

  def self.get_expire(key)
    have_expire?(key) ? @@storage[key][:expire] : -1
  end

  def self.set_value(key, value)
    have_expire?(key) ? @@storage[key][:value] = value
      : @@storage[key] = value
  end 

  def self.set_expire(key, time)
    @@storage[key] = {value: value(key), expire: time}
    p @@storage[key]
  end

  def self.have_expire?(key)
    @@storage[key].class == Hash
  end
  
end