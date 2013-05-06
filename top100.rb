require 'nokogiri'
require 'open-uri'
require 'youtube_it'
require 'viddl-rb'
require 'find'
require 'thread'

@client = YouTubeIt::Client.new
@titles=[]
@artists=[]
@albums=[]
@tracks=[]
pages = ['100-91.php', '90-86.php', '85-81.php', '80-76.php', '75-71.php', '70-66.php', '65-61.php', '60-56.php', '55-51.php', '50-41.php', '40-36.php', '35-31.php', '30-26.php', '25-21.php', '20-16.php', '15-11.php', '10-06.php', '05.php', '04.php', '03.php', '02.php', '01.php' ]

def parse(pages)
  pages.each do |page|
    doc = Nokogiri::HTML(open("http://www.abcdrduson.com/100-classiques-rap-francais/#{page}"))
    #Tracks titles into titles tab
    doc.css('h2').each do |h2|
      @titles << sanitize(h2.content)
    end
    #Tracks' artists into artists tab
    doc.css('h3').each do |h3|
      @artists << sanitize(h3.content)
    end
    #Tracks albums titles into albums tab
    doc.css('small').each do |small|
      @albums << sanitize(small.content)
    end
  end
  return @titles, @artists, @albums
end


def download(titles, artists, albums)
  i = @titles.count
  c = 0
  #The first entry of my tab is the last track of the top 100
  #Each tabs as the same number of entries
  @titles.each do |title|
  @string = "#{i}- #{title} - #{artists[c]}"
  #Creating a full string with the song title, the artist and the album 
    #Using the youtube search to find a result for this track and adding it to the string
    results = @client.videos_by(:query => "#{title} #{artists[c]}", :fields => {:view_count => "1000"})
    if results.total_result_count > 0 && results.videos.count > 0
      video_url = results.videos.first.player_url
      `viddl-rb #{video_url}` #Downloading the video using viddlrb gem
      renaming_last_file(@string)
      convert_to_mp3(@string) 
      fill_the_id3_tags(artists[c], albums[c], title, i, @string)
    else
      @tracks << "#{@string} || Video not found"
    end
    i-=1
    c+=1
  end
  return @tracks
end

def not_found(tracks)
  #Creating a notfound.txt file, and putting all the not found songs into it.
  File.open("notfound.txt", "w") { |f| f.puts @tracks.join("\n") }
end

def renaming_last_file(string)
  file = last_modified_file  
  ext = File.extname(file)
  if file !~ /^\d{1,3}/ 
    File.rename(File.join(File.dirname(__FILE__), file ), "#{@string}#{ext}")
    `ls -al "#{@string}#{ext}"`
  else
    @tracks << "#{@string} || Audio not found"
  end
end

def convert_to_mp3(string)
  file = last_modified_file  
  ext = File.extname(file)
  if ext != '.webm'
    @tracks << "#{@string} || Failed to convert into MP3"
  else
  `ffmpeg -i '#{@string}#{ext}' -acodec libmp3lame -aq 4 '#{@string}.mp3'`
  end
end

def fill_the_id3_tags(artist, album, title, track_number, file_name)
  audio_file = last_modified_file  
  ext = File.extname(audio_file)
  if ext == '.mp3'
    `eyeD3 -a '#{artist}' -A '#{album}' -t '#{title}' -n #{track_number} '#{file_name}.mp3'`
  end
end

def last_modified_file
  Dir['*'].sort_by{ |f| File.mtime(f) }.last
end

def delete_webm_and_ogg_files
  files = []
  Find.find('.') do |f|
      files << f if File.extname(f) == '.webm' || File.extname(f) == '.ogg'
    end
  files.each do |f|
    File.delete(f)
  end   
end

def sanitize(filename)
  filename.strip.tap do |name|
  name.gsub!(/^.*(\\|\/)/, '')
  name.gsub!(/[^ [[:alpha:]].\-]/, '')
  end
end


parse(pages)
download(@titles, @artists, @albums)
not_found(@tracks)
delete_webm_and_ogg_files



