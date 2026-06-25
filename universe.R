#remotes::install_github("kwb-r/pkgmeta")
install.packages("pkgmeta", repos = "https://kwb-r.r-universe.dev/")
remotes::install_github("kwb-r/pkgmeta")
remotes::install_github("kwb-r/kwb.pkgstatus@dev")
writeLines(pkgmeta::create_universe_pkgs_json(github_token = ""),
           "packages.json")


read_github_remotes <- function(repo){
  message("Checking:", repo)
  url <- paste0(repo, "/raw/HEAD/DESCRIPTION")
  desc <- as.data.frame(read.dcf(url(url)))
  if(length(desc$Remotes)){
    trimws(strsplit(desc$Remotes, ',')[[1]])
  }
}

read_github_remotes <- function(repo) {
  message("Checking: ", repo)
  url <- paste0(repo, "/raw/HEAD/DESCRIPTION")
  desc <- tryCatch(
    as.data.frame(read.dcf(url(url))),
    error = function(e) { message("  uebersprungen (", conditionMessage(e), ")"); NULL }
  )
  if (!is.null(desc) && !is.null(desc$Remotes)) {
    trimws(strsplit(desc$Remotes, ",")[[1]])
  }
}

kwb <- jsonlite::fromJSON("packages.json")

all_remotes <- lapply(kwb$url, read_github_remotes)
remotes <- sub("github::", "", unlist(all_remotes))
remotes <- sub("@.*$", "", remotes)   # @branch entfernen
remotes <- unique(remotes)            # Originalschreibweise behalten

remote_urls <- paste0("https://github.com/", remotes)

# case-insensitiver Abgleich -> KWB-R-Selbstreferenzen gelten NICHT als fehlend
missing  <- remotes[!tolower(remote_urls) %in% tolower(kwb$url)]

pkg_name <- basename(missing)

new_entries <- data.frame(
  package = pkg_name,
  url     = paste0("https://github.com/", missing),
  noindex = TRUE,
  stringsAsFactors = FALSE
)

kwb$noindex = NA
merged <- rbind(kwb, new_entries)
merged <- merged[!duplicated(tolower(merged$url)), ]
merged <- merged[order(tolower(merged$package)), ]   # alphabetisch

jsonlite::write_json(merged, "packages.json", pretty = TRUE, auto_unbox = TRUE)
message(nrow(new_entries), " Pakete ergaenzt, insgesamt ", nrow(merged))
