module Cuirator
  class ObjectFactory < Bulkrax::ObjectFactory

    # Allow attributes to create Hyrax::ControlledVocabulary::Location 
    class_attribute :controlled_vocabulary_attributes,
      default: %i[ based_near_attributes ]

    # Include additional attributes
    def permitted_attributes
      super + controlled_vocabulary_attributes
    end

  end
end