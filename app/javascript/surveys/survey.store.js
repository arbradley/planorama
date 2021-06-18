import { survey_columns, Surveys } from './survey';
import { PlanoStore } from '../model.store'

export const store = new PlanoStore(new Surveys(), survey_columns, {
  selected_page_id: undefined,
  selected_question_id: undefined
});
