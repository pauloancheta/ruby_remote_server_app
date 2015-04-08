# This program runs an infinite loop and takes a string from a remote server
# The string is separated having a url and file name.
# The program checks if the file is already stored in the database; if not, it stores the data
# Finally, it launches the file.

require 'net/http'
require 'json'
require 'launchy'

# STATIC VARIABLES
NEW_FILE_URI      = URI('http://localhost:2345/index.html')  # default Apache server
DATABASE_URI      = URI('http://localhost:3000/db.json')     # mock server with JSON get data
DATABASE_POST_URI = URI('http://localhost:3000/videos')      # mock post server

# GET HTTP RESPONSE
new_file = Net::HTTP.get_response(NEW_FILE_URI)
database = Net::HTTP.get_response(DATABASE_URI)

# INITIALIZE FILENAMES
new_file_name, new_file_url = ""
new_file_array              = new_file.body.split(' ')


# SEPARATE FILE NAME AND URL
if new_file_array.count > 1 
  # if string is separated between URL and filename, use these conditions
  # for example www.google.com/SWKJER video.mp4
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
  # for example www.google.com/video.mp4
  new_file_name = new_file_array[ (new_file_array.rindex('/') + 1)..new_file_array.length ]
  new_file_url = new_file_array[ 0..new_file_array.rindex('/') ]
end


# RUN INFINITE LOOP TO CHECK UPDATES FROM SERVER
while 1 
  # compare with file_name with database
  result =  JSON.parse(database.body)
  count = 0

  # iterate over the JSON and check every file name and find a match
  # if no results are found, post the data into the remote database
  while count < result.count
    if new_file_name != result[count]["name"]
      res = Net::HTTP.post_form(DATABASE_POST_URI, 'filename' => new_file_name, 'video' => new_file_url)
    end
    count = count + 1
  end
end

# LAUNCH VIDEO
Launchy.open(database_uri)