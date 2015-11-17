module Notifications
  def Notifications.get_all()
    rVal = Array.new
    rVal.push("Heads up! This site is a work in progess. Some things might not work the way they should.")
    rVal.push("HEROKU: This build is on ring DEV-PUB, which is marked as unstable.")
    # Insert other global notifications here
    return rVal
  end
end
