require 'rails_helper'

describe Concerns::FileSetBehavior do
  before do
    class TestClass < ActiveFedora::Base
      include Concerns::FileSetBehavior
    end
  end

  describe 'adds properties' do
    { bit_rate: RDF::Vocab::EBUCore.bitRate,
      codec_long_name: RDF::Vocab::EBUCore.codecName,
      codec_name: RDF::Vocab::EBUCore.hasCodec,
      codec_type: RDF::Vocab::EBUCore.hasMedium,
      date_generated: RDF::Vocab::EBUCore.dateCreated,
      file_format_long_name: RDF::Vocab::EBUCore.hasFileFormat,
      file_format: RDF::Vocab::PREMIS.hasFormatName,
      file_name: RDF::Vocab::EBUCore.filename,
      format_duration: RDF::Vocab::EBUCore.duration,
      format_file_size: RDF::Vocab::EBUCore.fileSize,
      format_sample_rate: RDF::Vocab::EBUCore.sampleRate,
      identifier: RDF::Vocab::EBUCore.identifier,
      md5_checksum: RDF::Vocab::NFO.hashValue,
      part: RDF::Vocab::EBUCore.partNumber,
      quality_level: RDF::Vocab::EBUCore.encodingLevel,
      title: RDF::Vocab::EBUCore.title,
      unit_of_origin: RDF::Vocab::EBUCore.comments,
      video_height: RDF::Vocab::EBUCore.height,
      video_width: RDF::Vocab::EBUCore.width }.each do |attribute, predicate|
      specify "#{attribute} => #{predicate}" do
        expect(TestClass.properties[attribute.to_s].predicate).to eq predicate
      end
    end
  end

  after do
    Object.send(:remove_const, :TestClass)
  end
end
