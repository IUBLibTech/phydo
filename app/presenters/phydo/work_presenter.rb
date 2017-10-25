module Phydo
  class WorkPresenter < Hyrax::WorkShowPresenter

    delegate :digitized_by_entity, :digitized_by_staff, :mdpi_timestamp, :extraction_workstation, :digitization_comments,
             :original_identifier, :definition, :unit_of_origin, :original_format, :recording_standard,
             :image_format, :system_create, :system_modified, :hardware,
             to: :solr_document

  end
end
