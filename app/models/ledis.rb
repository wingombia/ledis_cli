class Ledis
  LOG_FILE = Rails.root.join("log.txt")
  DUMP_FILE = Rails.root.join("dump.txt")
  @@storage = {}
  ###STRING###

  def self.set(key:, value:)
    @@storage[key] = value
    "OK"
  end

  def self.get(key:)
    touch(key: key)
  end
  
  ###DATA_EXPIRATION###

  def self.keys
    @@storage.keys
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
    if key_val = touch(key: key)
      return "ERROR" if key_type(key) != Set
    else
      @@storage[key] = Set.new
      key_val = @@storage[key]
    end

    count = 0
    Array(values).each do |val|
      count += 1 if key_val.add?(val) 
    end
    count
  end

  def self.srem(key:, values:)
    if key_val = touch(key: key)
      return "ERROR" if key_type(key) != Set
    else
      return 0
    end 

    count = 0
    Array(values).each do |val|
      count += 1 if key_val.delete?(val)
    end
    count
  end

  def self.smembers(key:)
    if key_val = touch(key: key)
      return "ERROR" if key_type(key) != Set
    else
      return "Empty list or set"
    end
    key_val
  end

  def self.sinter(keys:)
    result = nil
    keys.each do |key|
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
    return "No dump file" if !DUMP_FILE.exist?
    @@storage = {}
    FileUtils.cp(file_path, LOG_FILE)
    load
  end

  private

  def self.key_type(key)
    value(key).class
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