require 'pony'
require_relative 'pagevars'

module Mailer
  def send(to, subject, body)
    Pony.mail({
      :from => Pagevars.setVars("ADMINMAIL"),
      :to => to,
      :subject => subject,
      :body => body
    })
  end
end
