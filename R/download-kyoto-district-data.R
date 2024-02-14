#' Download the Kyoto Prefecture administrative district data
#'
#' @description
#' Download the Kyoto Prefecture administrative district data
#' provided by the Ministry of Land, Infrastructure, Transport and Tourism.
#'
#' @param download_dir A directory where downloaded file is to saved.
#' @return Path of the downloaded file (invisibly).
#' @examples
#' \dontrun{
#' download_kyoto_district_data("download-dir-path")
#' }
download_kyoto_district_data <- function(download_dir = getwd()) {
  url <- "https://nlftp.mlit.go.jp/ksj/gml/data/N03/N03-2023/N03-20230101_26_GML.zip"
  destfile <- file.path(download_dir, basename(url))

  if (file.exists(destfile)) {
    cli_alert_warning("The file {.path {destfile}} already exists")
    cli_alert_info("Skip downloading")
    return(invisible(destfile))
  }

  downloaded_file_path <- curl_download(url, destfile)
  cli_alert_success("Downloaded the file {.path {downloaded_file_path}}")

  return(invisible(downloaded_file_path))
}
