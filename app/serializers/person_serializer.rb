class PersonSerializer < ActiveModel::Serializer
  attributes :id, :lock_version,
             :name, :name_sort_by, :name_sort_by_confirmed,
             :pseudonym, :pseudonym_sort_by, :pseudonym_sort_by_confirmed,
             :published_name, :published_name_sort_by,
             :job_title, :organization,
             :pronouns, :year_of_birth, :gender, :ethnicity,
             :opted_in, :comments,
             :can_share, :can_photo, :can_record,
             :invite_status, :acceptance_status,
             :registered, :registration_type, :registration_number

  has_one :bio

  # tag_list
  attribute :tags do
    object.base_tags.collect(&:name)
  end
end
