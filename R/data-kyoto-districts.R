globalVariables("kyoto_districts")

#' Kyoto prefecture administrative district data
#'
#' Information on administrative areas such as cities and wards
#' in Kyoto Prefecture.
#'
#' @format Each is a tibble with 36 rows 5 variables:
#' \describe{
#' \item{city}{City names}
#' \item{city_code}{City codes}
#' \item{city_kanji}{City names in japanese}
#' \item{area}{Area of the city (m^2)}
#' \item{geom}{Geometry data (polygon or multi-polygon type) of boundaries}
#' }
#' @examples
#' kyoto_districts
#' @name kyoto_districts
"kyoto_districts"
