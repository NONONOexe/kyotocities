#' Find fire stations by city name
#'
#' @description
#' The function returns the fire station data of the specified city name.
#' The search is performed with partial matches.
#'
#' @param city_name Part of the city name
#' @return fire station data of the specified city name
#' @export
#' @examples
#' \dontrun{
#' fukuchiyama_fire_stations <- find_fire_stations("Fukuchiyama-shi")
#' }
find_fire_stations <- function(city_name) {
  data("kyoto_fire_stations", package = "kyotocities", envir = environment())
  fire_stations <- kyoto_fire_stations
  districts <- find_districts(city_name)
  return(st_filter(fire_stations, districts))
}
