module LedisExceptions
    class WrongType < StandardError
    def initialize(msg = "Operation against a key holding the wrong kind of value")
        super
    end
    end

    class NoCommand < StandardError
    def initialize(msg = "Not recognized command")
        super
    end
    end
end