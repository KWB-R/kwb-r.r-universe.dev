remotes::install_github("kwb-r/pkgmeta@dev")
writeLines(pkgmeta::create_universe_pkgs_json(github_token = ""),
           "packages.json")
