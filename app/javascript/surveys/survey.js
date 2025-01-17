import PlanoModel from '../model.js';
import {Collection} from 'vue-mc';
import {
    required,
    string,
} from 'vue-mc/validation'

export class Survey extends PlanoModel {
  schema() {
    let s = super.schema()
    delete s.survey_pages
    return s
  }
  defaults() {
    return {
      id: null,
      name: '',
      welcome: null,
      thank_you: null,
      alias: '',
      submit_string: '',
      header_image: null,
      use_captcha: false,
      public: false,
      authenticate: false,
      //transition_accept_status: false,
      //transition_decline_status: false,
      declined_msg: '',
      anonymous: false,
      survey_pages: [{
        id: null,
        title: null,
        survey_questions: [{
          id: null,
          question: '',
          question_type: 'textfield',
          survey_answers: [{
            id: null,
            answer: '',
          }]
        }]
      }]
    }
  }
  validation() {
    return {
      name: string.and(required)
    }
  }
  routes() {
    return {
      fetch: '/surveys/{id}',
      create:  '/surveys',
      save:  '/surveys/{id}',
      update: '/surveys/{id}',
      delete: '/surveys/{id}'
    }
  }

  getSaveData() {
    const data = super.getSaveData()
    if(data.survey_pages) {
      data.survey_pages_attributes = data.survey_pages.map((page, i) => {
        if (page.survey_questions) {
          page.survey_questions_attributes = page.survey_questions.map((q, j) => {
            if(q.survey_answers) {
              q.survey_answers_attributes = q.survey_answers.map((a, k) => {
                a.sort_order = k
                return a
              })
            }
            q.sort_order = j;
            return q
          })
        }
        page.sort_order = i
        return page
      })
    }
    return data;
  }
};

export class Surveys extends Collection {
  options() {
    return {
      model: Survey,
    }
  }

  defaults() {
    return {
      sortField: 'name',
      sortOrder: 'asc',
      filter: '',
      perPage:15,
      page: 1,
      total: 0
    }
  }

  routes() {
    return {
      fetch: '/surveys?perPage={perPage}&sortField={sortField}&sortOrder={sortOrder}&filter={filter}',
    }
  }
};

export const survey_columns = [
  {
    key: '$.name',
    label: 'Name',
    stickyColumn: true,
    sortable: true
  },
  'description',
  {
    key: '$.public',
    label: 'Status',
    formatter: (p) => p ? 'Published' : 'Closed'
  },
  'publishedOn', // needs sortable
  {
    key: '$.updated_at',
    label: 'Last Modified On',
    sortable: true,
    formatter: (d) => new Date(d).toLocaleDateString()
  },
  'lastModifiedBy', // needs sortable
  'preview',
  'surveyLink',
  // welcome
  // thank_you
  // alias
  // submit_string
  // header_image
  // use_captcha
  // public
  // authenticate
  // transition_acceptance_status
  // transition_decline_status
  // declined_msg
  // anonymous
];

