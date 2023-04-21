module Cuirator
    class YearPresenter < GoogleScholarPresenter
        def work
          if Array(object.try(:human_readable_type)).first || "" == "Etd"
            return true
          end
        end
      end
end
    
  