module Phydo
  class CatalogSearchBuilder < Hyrax::CatalogSearchBuilder
    def models
      super + [::FileSet]
    end
  end
end
