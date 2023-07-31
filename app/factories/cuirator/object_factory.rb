module Cuirator
  class ObjectFactory < Bulkrax::ObjectFactory

    # Allow attributes required to create Hyrax::ControlledVocabulary::Location values
    class_attribute :controlled_vocabulary_attributes,
      default: %i[ based_near_attributes ]

    # Include additional attributes
    def permitted_attributes
      super + controlled_vocabulary_attributes
    end

  end
end