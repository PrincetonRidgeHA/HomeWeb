module Notifications
  def Notifications.getAll()
    rVal = Array.new
    counter = 0;
    rVal[counter] = "Heads up! This site is a work in progess. Some things might not work the way they should."
    counter++
    # Insert other global notifications here
    return rVal
  end
end
