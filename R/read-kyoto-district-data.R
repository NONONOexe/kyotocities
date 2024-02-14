#' Read the Kyoto Prefecture administrative district data
#'
#' @description
#' Read the Kyoto Prefecture administrative district data.
#'
#' @param file A file path of data to read.
#' @return Information on administrative areas such as cities and wards
#' in Kyoto Prefecture.
#'
#' @format Each is a tibble with 69 rows 6 variables:
#' \describe{
#' \item{city}{City names}
#' \item{city_code}{City codes}
#' \item{city_kanji}{City names in japanese}
#' \item{geom}{Geometry data (polygon or multi-polygon type) of boundaries}
#' }
#'
#' @export
#' @examples
#' \dontrun{
#' kyoto_districts <- read_kyoto_district_data("N03-20230101_26_GML.zip")
#' }
read_kyoto_district_data <- function(file) {
  # Unzip the file.
  cli_progress_step("Unzipping the file into {.path {tempdir()}}")
  unzipped_path <- unzip(file, exdir = tempdir())

  # Data frame of city names.
  city_names <- tibble(
    "city_code" = c(
      "26101", "26102", "26103", "26104", "26105", "26106",
      "26107", "26108", "26109", "26110", "26111", "26201",
      "26202", "26203", "26204", "26205", "26206", "26207",
      "26208", "26209", "26210", "26211", "26212", "26213",
      "26214", "26303", "26322", "26343", "26344", "26364",
      "26365", "26366", "26367", "26407", "26463", "26465"
    ),
    "city" = c(
      paste("Kyoto-shi", c(
        "Kita-ku", "Kamigyo-ku", "Sakyo-ku", "Nakagyo-ku",
        "Higashiyama-ku", "Shimogyo-ku", "Minami-ku",
        "Ukyo-ku", "Fushimi-ku", "Yamashina-ku", "Nishikyo-ku"
      )),
      "Fukuchiyama-shi", "Maizuru-shi", "Ayabe-shi", "Uji-shi", "Miyazu-shi",
      "Kameoka-shi", "Jyoyo-shi", "Muko-shi", "Nagaokakyo-shi", "Yawata-shi",
      "Kyotanabe-shi", "Kyotango-shi", "Nantan-shi", "Kizugawa-shi",
      "Otokuni-gun Oyamazaki-cho", "Kuze-gun Miyama-cho",
      paste("Tsuzuki-gun", c("Ide-cho", "Ujitawara-cho")),
      paste("Soraku-gun", c(
        "Kasagi-cho", "Wazuka-cho",
        "Seika-cho", "Minamiyamashiro-mura"
      )),
      "Funai-gun Kyotanba-cho",
      paste("Yosa-gun", c("Ine-cho", "Yosano-cho"))
    )
  )

  # Create a data frame of city names and codes.
  shp_data_path <- unzipped_path[endsWith(unzipped_path, ".shp")]
  cli_progress_step("Reading the district data into a tibble")
  kyoto_districts <- shp_data_path |>
    read_sf(options = "ENCODING=CP932", stringsAsFactors = FALSE) |>
    transmute(
      city_code = .data$N03_007,
      city_kanji = str_trim(str_c(
        str_replace_na(.data$N03_002, ""),
        str_replace_na(.data$N03_003, ""),
        str_replace_na(if_else(str_starts(.data$N03_004, .data$N03_003),
          str_remove(.data$N03_004, .data$N03_003),
          .data$N03_004
        ), " "),
        sep = " "
      ))
    ) |>
    group_by(.data$city_code, .data$city_kanji) |>
    summarise(geom = st_union(.data$geometry), .groups = "drop") |>
    inner_join(city_names, by = join_by("city_code")) |>
    mutate(area = st_area(.data$geom)) |>
    arrange(.data$city_code) |>
    relocate("city_code", "city", "city_kanji", "area") |>
    st_transform(crs = 4326)

  return(kyoto_districts)
}
