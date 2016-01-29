module BuildData
  def BuildData.ci_get_commit()
    return 'TRAVISCOMMIT'
  end
  def BuildData.ci_get_build()
    return 'TRAVISBUILD'
  end
  def BuildData.get_ci_string()
    return ci_get_build() + '/' + ci_get_commit()
  end
end
