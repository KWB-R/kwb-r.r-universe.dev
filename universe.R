#remotes::install_github("kwb-r/pkgmeta")
install.packages("pkgmeta", repos = "https://kwb-r.r-universe.dev/")
writeLines(pkgmeta::create_universe_pkgs_json(github_token = ""),
           "packages.json")
