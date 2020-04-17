class Parser
  attr_accessor :lines
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
end