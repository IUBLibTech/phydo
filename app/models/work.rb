# Generated via
#  `rails generate curation_concerns:work Work`
require 'IU/models/concerns/work_behavior'


class Work < ActiveFedora::Base

  FIXITY_TYPE = :md5
  include ::CurationConcerns::WorkBehavior
  include ::CurationConcerns::BasicMetadata
  include ::IU::Models::Concerns::WorkBehavior
  # validates :title, presence: { message: 'Your work must have a title.' }

  def do_md5_checksum

  end

  def do_fixity_check
    do_md5_checksum if Work::FIXITY_TYPE == :md5
  end
end
