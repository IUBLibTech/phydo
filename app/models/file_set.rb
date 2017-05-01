class FileSet < ActiveFedora::Base
  include ::Hyrax::FileSetBehavior
  include ::Concerns::FileSetBehavior

  directly_contains_one :service_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#ServiceFile'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :intermediate_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#IntermediateFile'), class_name: 'Hydra::PCDM::File'
  directly_contains_one :preservation_master_file, through: :files, type: ::RDF::URI('http://pcdm.org/use#PreservationMasterFile'), class_name: 'Hydra::PCDM::File'

  has_many :preservation_events, class_name: Preservation::Event, inverse_of: :premis_event_related_object
  
  class << self
    def indexer
      ::FileSetIndexer
    end
  end
end
