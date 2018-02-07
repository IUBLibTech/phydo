require 'hyrax/preservation'

FactoryBot.define do
  factory :preservation_event, class: Hyrax::Preservation::Event do

    transient do
      premis_agent_email false
      premis_event_related_object nil
    end

    premis_event_type { [Hyrax::Preservation::PremisEventType.all.sample.uri] }
    premis_event_date_time { [DateTime.now - rand(30000).hours] }
    sequence(:premis_agent) { |n| [::RDF::URI.new("mailto:premis_agent_#{n}@phydo.org")] }

    after :build do |event, evaluator|
      if evaluator.premis_agent_email
        # Do not append to :premis_agent here. If :premis_agent_email was passed in, then we want
        # to use it instead of the default sequence for:premis_agent.
        event.premis_agent = [::RDF::URI.new("mailto:#{evaluator.premis_agent_email}")]
      end

      if evaluator.premis_event_related_object
        event.premis_event_related_object = evaluator.premis_event_related_object
      else
        premis_event_related_object = build(:file_set)
      end
    end
  end
end
