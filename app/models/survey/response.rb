class Survey::Response < ApplicationRecord
  belongs_to :survey_question,
             class_name: 'Survey::Question',
             foreign_key: 'survey_question_id'

  belongs_to :survey_submission,
             class_name: 'Survey::Submission',
             foreign_key: 'survey_submission_id',
             inverse_of: :survey_responses

  before_save :set_response_text

  #
  # Extract the values from all the entries and save a plain text
  # version that can be used for searchin the responses in a "report"
  #
  def set_response_text
    flattened_response = flatten_response(response)
    self.response_as_text = flattened_response.values.join(' ').strip
  end

  #
  def flatten_response(hash)
    hash.each_with_object({}) do |(k, v), h|
      if v.is_a? Hash
        flatten_response(v).map do |h_k, h_v|
        h["#{k}.#{h_k}".to_sym] = h_v
        end
      else
        h[k] = v
      end
    end
  end
end
