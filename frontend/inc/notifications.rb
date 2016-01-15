module Notifications
  def Notifications.get_all()
    rVal = Array.new
    if(ENV['HEROKU_PIPELINE'] == 'staging')
      rVal.push("WARNING: You are using the development version of this site.")
    end
    # Insert other global notifications here
    return rVal
  end
end
