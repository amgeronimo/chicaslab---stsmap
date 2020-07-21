get_recent_line_listing <- function(root){
    ## find the most recent Line listing file from `root` folder
    dated_folders = list.files(root, pattern=".*20[0-9][0-9]-[0-1][0-9]-[0-3][0-9]$", recursive=FALSE, full.names=TRUE,include.dirs=TRUE)
    last_folder = sort(dated_folders, decreasing=TRUE)[1]
    xlsx = Sys.glob(file.path(last_folder, "Anon*Line*xlsx"))
    return(xlsx)
}
