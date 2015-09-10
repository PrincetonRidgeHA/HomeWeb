require_once 'pony'
require_relative 'pagevars'

module Mailer
  def send(String to, String subject, String body)
    Pony.mail({
      :from => Pagevars.setVars("ADMINMAIL"),
      :to => to,
      :subject => subject,
      :body => body
    })
  end
end
