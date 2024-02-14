library(sf)
library(osmdata)
library(kyotocities)
library(dplyr)
library(purrr)
library(stringr)

# Create a query to get all fire stations in Kyoto
fire_station_opq <- kyoto_districts |>
  st_bbox() |>
  opq() |>
  add_osm_feature(key = "amenity", value = "fire_station")

# Get the data in OSM format
fire_station_osm <- osmdata_sf(fire_station_opq)

# Extract data within Kyoto Prefecture
osm_points <- fire_station_osm |>
  pluck("osm_points") |>
  st_filter(kyoto_districts) |>
  select(name, geom = geometry)
osm_polygons <- fire_station_osm |>
  pluck("osm_polygons") |>
  st_filter(kyoto_districts) |>
  select(name, geom = geometry)

# Remove points that are within the polygons
polygonized_areas <- osm_polygons |>
  st_union() |>
  st_transform(6674) |>
  st_buffer(10) |>
  st_transform(4326)
filtered_points <- osm_points |>
  st_filter(polygonized_areas, .predicate = st_disjoint) |>
  as_tibble() |>
  transmute(name, geom) |>
  st_as_sf()

# Remove overlapping polygons and
fixed_poligons <- osm_polygons |>
  st_union() |>
  st_cast("POLYGON") |>
  st_as_sf() |>
  mutate(id = row_number()) |>
  st_join(osm_polygons) |>
  distinct()
st_geometry(fixed_poligons) <- "geom"

# Replace unnamed polygons with named points
unnamed_polygons <- fixed_poligons |>
  filter(is.na(name)) |>
  select(id)
replacements <- osm_points |>
  filter(!is.na(name)) |>
  st_join(unnamed_polygons, left = FALSE) |>
  as_tibble() |>
  nest_by(id) |>
  ungroup() |>
  mutate(data = map(data, \(x) x |> slice_max(str_length(name)))) |>
  unnest(data)

# Set the centroid of each polygon as the location of the fire station
building_centroids <- fixed_poligons |>
  filter(!id %in% replacements$id) |>
  bind_rows(replacements) |>
  transmute(name, geom = st_centroid(geom))

kyoto_fire_stations <- bind_rows(filtered_points, building_centroids)

# Set the encoding to UTF-8
Encoding(kyoto_fire_stations$name) <- "UTF-8"

usethis::use_data(kyoto_fire_stations, overwrite = TRUE)
