require 'json'
require 'postmark'

module Email
    def send(data)
        recipient_list = data['to']
        recipient_list.split(', ').each do |recipient|
            client = Postmark::ApiClient.new(ENV['POSTMARK_API_KEY'])
            client.deliver(
                to: recipient,
                subject: data['subject'],
                html_body: data['content'],
                track_opens: true)
        end
    end
end