# stsmap repository

This repository generates the web page from the latest sts model output
in the `days` folder. The `stsmodel` repository contains the 
code for fitting the model and generating the daily folders. 

## Usage

Create a folder with an ISO 8601-compliant name in `./days`. Add,
commit, and push to `gitlab.com`, and when gitlab CI runs the folder
with the latest date will become the current web page at
https://chicas-covid19.gitlab.io/stsmap/ - this repository doesn't
care what's in the folder. It just copies it.

If you want to browse the historical predictions, check out the repository 
and browse `./days` in a web browser.

## History

This used to be an R package that created the web pages from the model output
but that code is now in `stsmodel` which does everything.

