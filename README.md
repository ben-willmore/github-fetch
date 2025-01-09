  ## github-fetchdir: Fetch a directory from Github with minimal dependencies
  
  Syntax: github-dir \<url\> [\<dest_dir\>] where \<url\> is of the form:
  https://github.com/ben-willmore/portmaster/tree/main/perfectdark
  https://github.com/ben-willmore/portmaster/tree/50c7502bc0b04f61dd94939735302c8d8fc18c4d/perfectdark
  and can be pasted from a browser page that shows a directory
  
  If \<dest_dir\> is supplied, the fetched directory will be put there\;
  otherwise it will be put in the current directory.
  
  This should work on any unix system with basic tools installed
  \(bash, sed, grep, ...\), including jq and either curl or wget. 