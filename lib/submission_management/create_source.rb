module SubmissionManagement
  class CreateSource
    SOURCE_MAP = {
      Types::Source::EMAIL => SubmissionManagement::Sources::Email
    }

    def call(source_type:, **params)
      source = nil

      return { error: "Invalid source type `#{source_type}`" } unless SOURCE_MAP.key?(source_type)

      source = SOURCE_MAP[source_type].new.call(**params)

      return { error: "Failed to create source: #{source[:error]}" } if source[:error]

      { source: source[:source] }
    end
  end
end
