require 'pony'
require_relative 'pagevars'

module Mailer
  ##
  # Wrapper to Pony gem for sending mail
  # using external SMTP services.
  def send(to, subject, body)
    Pony.mail({
      :from => Pagevars.setVars("ADMINMAIL"),
      :to => to,
      :subject => subject,
      :body => body
    })
  end
end
