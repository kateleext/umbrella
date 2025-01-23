# Write your soltuion here!

#loading all the gems
require "dotenv/load"
require "http"
require "json"
require "ascii_charts"

pp "Where are you?"
user_location = gets.chomp
pp "Checking the weather for #{user_location}..."
user_location = user_location.gsub(" ","+")

#get the geolocation from google maps
gmaps_key = ENV.fetch("GMAPS_KEY")
gmaps_url = "https://maps.googleapis.com/maps/api/geocode/json?address=#{user_location}&key=#{gmaps_key}"
gmaps_response = JSON.parse(HTTP.get(gmaps_url))
coordinates = gmaps_response.fetch("results")[0].fetch("geometry").fetch("location")
address = gmaps_response.fetch("results")[0].fetch("formatted_address")
lat = coordinates.fetch("lat")
lng = coordinates.fetch("lng")
pp "Your coordinates are #{lat}, #{lng}"

#get the weather at the user's coordinates 
pirate_weather_key = ENV.fetch("PIRATE_WEATHER_KEY")
pirate_weather_url = "https://api.pirateweather.net/forecast/#{pirate_weather_key}/#{lat},#{lng}"
pirate_response = JSON.parse(HTTP.get(pirate_weather_url))

current_temp = pirate_response.fetch("currently").fetch("temperature")
current_summary = pirate_response.fetch("currently").fetch("summary")
pp "It is currently #{current_summary}, at #{current_temp} degrees."

#next hour precipitation
next_hour_precip_prob = pirate_response.fetch("hourly").fetch("data")[0].fetch("precipProbability") * 100
next_hour_precip_type = pirate_response.fetch("hourly").fetch("data")[0].fetch("precipType").downcase
if next_hour_precip_prob > 0
  pp "There is a #{next_hour_precip_prob}% chance of #{next_hour_precip_type} in the next hour."
end

#rain chart
#based on the docs, i need an array of x-y pairs
chart_data = []
hourly_forecast = pirate_response.fetch("hourly").fetch("data")[0,12]

hourly_forecast.each_with_index do |forecast,count|
  precip = forecast.fetch("precipProbability")
  hour = count+1
  data = [hour,precip]
  chart_data.push(data)
end
puts "-----------------"
puts "Hours from Now vs. Percipitation Probability"
puts AsciiCharts::Cartesian.new(chart_data, :bar => true).draw
