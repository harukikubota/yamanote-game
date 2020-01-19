station_names =
  %w[
    東京
    神田
    上野
  ]

station_names.each do |name|
  Station.create(
    name: name
  )
end
