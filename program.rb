# This program runs an infinite loop and takes a string from a remote server
# The string is separated having a url and file name.
# The program checks if the file is already stored in the database; if not, it stores the data
# Finally, it launches the file.

require 'net/http'
require 'json'
require 'launchy'


new_file_uri = URI('http://localhost:2345/index.html')        # default Apache server
database_uri = URI('http://localhost:3000/db.json')  # mock server with JSON get data
database_post_uri = URI('http://localhost:3000/users')        # mock post server

# get HTTP responses
new_file = Net::HTTP.get_response(new_file_uri)
database = Net::HTTP.get_response(database_uri)

# initialize filenames
new_file_name, new_file_url = ""
new_file_array = new_file.body.split(' ')


if new_file_array.count > 1 
  # if string is separated between URL and filename, use this conditions
  if new_file_array[0].include?('www')
    new_file_name  = new_file_array[1]
    new_file_url = new_file_array[0]
  else
    new_file_name  = new_file_array[0]
    new_file_url = new_file_array[1]
  end
else
  # if string is one word and filename is in the url,
  # these lines separate the url and filename and assigns it to the new_file_name and new_file_url variable
  new_file_name = new_file_array[ (new_file_array.rindex('/') + 1)..new_file_array.length ]
  new_file_url = new_file_array[ 0..new_file_array.rindex('/') ]
end


while 1 # run infinite loop to check updates from incoming server
  # compare with file_name with database
  result =  JSON.parse(database.body)
  count = 0
  while count < result.count
    # if the file_name is not in the database, store the video in the database
    if new_file_name != result[count]["name"]
      res = Net::HTTP.post_form(database_post_uri, 'filename' => new_file_name, 'video' => new_file_url)
    end
    count = count + 1
  end
end

# finally play the video
Launchy.open(database_uri)