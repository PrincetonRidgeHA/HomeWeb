module Pagevars
  ##
  # Load wrapped Builddata module.
  begin
    if ENV['env'] == 'production'
      require_relative './builddata'
    else
      require_relative '../builddata.partial'
    end
  rescue
    raise "Missing builddata file"
  end
  ##
  # Gets a variable from the dynamic Builddata module.
  def Pagevars.set_vars(vname)
    if vname == "CIbuild"
      return BuildData.ci_get_build()
    elsif vname == "ADMINMAIL"
      return "wordman05@gmail.com"
    elsif vname == "ADMINNAME"
      return "Joshua Zenn"
    else
      return "Error"
    end
  end
end
