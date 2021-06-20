#setup_type

#This seed should only create these items if they don't already exist.
#This seed should run to populate the production db as well as the development and other dbs.

rows = [
    {name: 'Theater', description: 'Set up room theater style with chairs in rows facing tables at head of room.'},
    {name: 'Open Room', description: 'Set up room with nothing in it.'},
    {name: 'Chair Circle', description: 'Set up room with chairs in a circle facing inward.'},
    {name: 'Other', description: 'Other'}
]

rows.each do |row|
    SetupType.where(name: row[:name]).find_or_create_by(row)
end

p "There are #{SetupType.count} room setup types."
