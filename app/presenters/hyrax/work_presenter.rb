module Hyrax
  class WorkPresenter < Hyrax::WorkShowPresenter

    delegate :digitized_by_entity, :digitized_by_staff, :mdpi_timestamp, :extraction_workstation, :digitization_comments,
             :original_identifier, :definition, :mdpi_barcode, :unit_of_origin, :original_format, :recording_standard,
             :image_format, :system_create, :system_modified, :encoder, :ad, :tbc,
             to: :solr_document

  end
end
