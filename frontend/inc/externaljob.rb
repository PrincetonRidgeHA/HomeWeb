require 'json'
require 'bunny'

class ExternalJob
    @task_name = ""
    @data = ""
    
    ##
    # Queues a job to be completed outside of the current thread.
    def initialize(task, data)
        @task_name = task
        @data = data
    end
    def push()
        if(ENV['RACK_ENV'] != 'test')
            data = Hash.new
            data["task"] = @task_name
            @data.each do |key, value|
                data[key] = value
            end
            c = Bunny.new(ENV['RABBITMQ_BIGWIG_TX_URL'])
            c.start
            ch = c.create_channel
            q  = ch.queue("prha.outbound")
            x  = ch.default_exchange
            x.publish(data.to_json, :routing_key => q.name)
        else
            puts "RabbitMQ job blocked: testing environment"
        end
    end
end
