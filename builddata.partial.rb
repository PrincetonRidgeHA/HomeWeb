module Builddata
  def Builddata.ci_get_commit()
    return 'TRAVISCOMMIT'
  end
  def Builddata.ci_get_build()
    return 'TRAVISBUILD'
  end
  def Builddata.getCIstring()
    return ci_get_build() + '/' + ci_get_commit()
  end
end
