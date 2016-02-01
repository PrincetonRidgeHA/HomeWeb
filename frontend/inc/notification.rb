class Notification
    def initialize(name, message)
        @title = name
        @msg = message
    end
    ##
    # Refactors current Notification object into a string.
    def to_s()
        return @title + '|' + @msg
    end
end