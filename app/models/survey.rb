class Survey < ApplicationRecord
  # Survey contains a series of pages, pages contain a series of questions
  has_many :survey_pages, dependent: :destroy, class_name: "Survey::Page"
  accepts_nested_attributes_for :survey_pages, allow_destroy: true

  has_many :survey_questions, through: :survey_pages, class_name: 'Survey::Question'

  has_many :survey_submissions, class_name: 'Survey::Submission'

  before_destroy :check_for_use #, :check_if_public

  # transition_accept_status
  # transition_decline_status

  # TODO change last modified on survey_questions CUD
  # TODO track created/updated by

  private

  def check_for_use
    raise 'can not delete a survey that has responses in the system' if survey_submissions.any?
  end

  def check_if_public
    raise 'can not delete a survey that is public' if public
  end
end
