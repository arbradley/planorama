class Submission::ResponsesController < ResourceController
  MODEL_CLASS = 'Survey::Response'.freeze

  # TODO: need the survey id etc as a parameter to the collection/index method

  # TODO: do we need this controller
  def belong_to_class
    Submission
  end

  def belongs_to_relationship
    'survey_responses'
  end

end
