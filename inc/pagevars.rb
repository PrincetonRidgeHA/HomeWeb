module Pagevars
  begin
    require_relative 'builddata'
  rescue
    raise "Missing builddata file"
  end
  def Pagevars.setVars(vname)
    if vname == "CIbuild"
      return Builddata.CIgetBuild()
    elsif vname == "ADMINMAIL"
      return "wordman05@gmail.com"
    elsif vname == "ADMINNAME"
      return "Joshua Zenn"
    else
      return "Error"
    end
  end
end
