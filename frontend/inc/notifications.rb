require_relative 'notification'

module Notifications
  def Notifications.get_all()
    rVal = Array.new
    if(ENV['HEROKU_PIPELINE'] == 'staging')
      dev_msg = Notification.new('Unstable Codebase', 'You are using the development version of this site.')
      rVal.push(dev_msg)
    end
    # Insert other global notifications here
    return rVal
  end
end
