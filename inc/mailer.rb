require_once 'pony'

module Mailer
  def send(String sender, String to, String subject, String body)
    Pony.mail({
      :from => sender,
      :to => to,
      :subject => "AUTO: PRHA bug report",
      :body => body
    })
  end
end
