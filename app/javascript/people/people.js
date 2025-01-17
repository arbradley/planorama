import PlanoModel from '../model.js'
import {Collection} from 'vue-mc'
import {
    required,
    string,
} from 'vue-mc/validation'

export class Person extends PlanoModel {
  schema() {
    let schema = super.schema();
    schema.comments = {
      label: 'Comments',
      type: 'textarea',
      options: {
        maxlength: 2000
      }
    }
    delete schema.bio
    return schema
  }

  defaults() {
    return {
      name: null,
      name_sort_by: null,
      name_sort_by_confirmed: false,
      pseudonym: null,
      pseudonym_sort_by: null,
      pseudonym_sort_by_confirmed: false,
      pronouns: null,
      job_title: null,
      organization: null,
      registered: false,
      registration_type: null,
      registration_number: null,
      opted_in: false,
      can_share: false,
      can_photo: false,
      can_record: false,
      gender: null,
      ethnicity: null,
      year_of_birth: null,
      comments: null,
      bio: {
        bio: '',
        twitterinfo: null,
        photourl: null,
        facebook: null,
        linkedin: null,
        twitch: null,
        youtube: null,
        instagram: null,
        flickr: null,
        reddit: null,
        othersocialmedia: null,
        website: null,
      }
    }
  }
  validation() {
    return {
      name: string.and(required)
    }
  }
  routes() {
    // TODO: do we need a custom route for update instaed of save???
    // see http://vuemc.io/#model-request-custom
    return {
      fetch: '/people/{id}',
      create:  '/people',
      save:  '/people/{id}',
      update: '/people/{id}',
      delete: '/people/{id}'
    }
  }
};

export class People extends Collection {
  options() {
    return {
      model: Person,
    }
  }

  defaults() {
    return {
      sortField: 'published_name_sort_by',
      sortOrder: 'asc',
      filter: '',
      perPage: 30,
      page: 1,
      total: 0
    }
  }

  routes() {
    return {
      // fetch: '/people',
      fetch: '/people?perPage={perPage}&sortField={sortField}&sortOrder={sortOrder}&filter={filter}',
    }
  }
};

// task.$.name or task.saved('name') to reflect what is in the backend ...
export const people_columns = [
  {
    key: 'id',
    label: 'ID'
  },
  {
    key: '$.published_name',
    label: 'Published Name',
    sortable: true,
    sticky: true,
  },
  {
    key: '$.name',
    label: 'Name',
    sortable: true,
    sticky: true,
  },
  {
    key: '$.pseudonym',
    label: 'Pseudonym',
    sortable: true
  },
  {
    key: '$.pronouns',
    label: 'Pronouns',
    sortable: false
  },
  {
    key: '$.registered',
    label: 'Registered',
    sortable: true
  },
  {
    key: '$.registration_type',
    label: 'Registration Type',
    sortable: true
  },
  {
    key: '$.registration_number',
    label: 'Registration Number',
    sortable: true
  }
  // {
  //   field: '$.bio',
  //   label: 'Bio',
  //   width: '250',
  //   searchable: false,
  //   sortable: false
  // }
];
