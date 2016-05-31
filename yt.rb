#To be able to use this script you need to add yt gem into your gem file
#Then install youtube-dl and eyeD3 with brew install

require 'yt'

Yt.configuration.api_key = 'your_api_key'

channel = Yt::Channel.new url: 'Youtube channel URL'

channel.videos.each do |item|
	p "Downloading #{item.title}" 
	video_url = "https://www.youtube.com/watch?v=#{item.id}"
	artist = item.title.split("-").first.strip
	`youtube-dl --extract-audio --audio-format mp3  --audio-quality  0  --embed-thumbnail  --add-metadata --metadata-from-title "%(artist)s - %(title)s" -o "%(title)s.%(ext)s" "#{video_url}"`
	`eyeD3 -a "#{artist}" "#{item.title}.mp3"`
	p "#####################"
end

