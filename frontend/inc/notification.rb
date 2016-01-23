class Notification
    @@title = ''
    @@msg = ''
    def initialize(name, message)
        @@title = name
        @@msg = message
    end
    def to_s()
        return '#{@@title}|#{@@msg}'
    end
end