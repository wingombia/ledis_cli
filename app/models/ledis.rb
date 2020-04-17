class Ledis
  @@storage = {}
  def self.set(key:, value:)
    @@storage[key] = value
  end

  def self.get(key:)
    @@storage[key]
  end
  
  def self.storage
    @@storage
  end

  def self.read_file(file_path:)
    File.open("tmp.txt") do |f|
      lines = f.readlines.map(&:chomp)
      Parser.new(lines: lines).perform
    end
  end
end