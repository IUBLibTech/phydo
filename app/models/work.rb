# Generated via
#  `rails generate hyrax:work Work`
class Work < ActiveFedora::Base

  FIXITY_TYPE = :md5

  include ::Hyrax::WorkBehavior
  include ::Hyrax::BasicMetadata

  # TODO: Possibly change to Phydo::WorkMetadata
  include Concerns::WorkBehavior

  # Change this to restrict which works can be added as a child.
  # self.valid_child_concerns = []
  validates :title, presence: { message: 'Your work must have a title.' }

  self.human_readable_type = 'Work'

  def do_md5_checksum
    # no-op
  end

  def do_fixity_check
    do_md5_checksum if Work::FIXITY_TYPE == :md5
  end

  class << self
    def indexer
      ::WorkIndexer
    end
  end
end
