class ResponseHandler
  attr_reader :result, :type
  def initialize(result:, type:)
    @result = result
    @type = type
  end

  def perform
    response = send(handler(type))
    if response.class == Integer
        response = "(integer) #{response}"
    end
    response
  end

  private

  def handler(type)
    (type.downcase.to_s + "_handler").to_sym
  end

  def error_handler
    "<div class=\"error\">\t(error) #{result.class.to_s.demodulize} #{result.message} </div>"
  end

  def basic_handler
    result
  end

  def count_handler
    result
  end

  def list_handler
    return "(empty list or set)" if result.empty?
    response = ""
    result.each_with_index do |k, i|
        response += "#{i + 1}) \"#{k}\"<br>"
    end
    response[0..-5]
  end

  def bool_handler
    response = result ? 1 : 0
  end

  def value_handler
    "\"#{result}\""
  end
end