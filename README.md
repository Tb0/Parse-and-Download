This script is parsing some webpages (using nokogiri) and retrieve 100 elements containing tracks titles, artists, and albums.
Then, I'm searching on Youtube (using youtube-it) this track, downloading a .webm version (using viddl-rb) and converting it to mp3 (using ffmpeg).
This mp3 file will be filled with the correct mp3 ID3 tags using eyed3.
Feel free to use and to modify this script as you want. 