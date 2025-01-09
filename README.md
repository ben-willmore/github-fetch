## github-fetchdir: Fetch a directory from Github with minimal dependencies
  
Syntax: `github-fetchdir <url> [<dest_dir>]`, where <url> is of the form:

`https://github.com/ben-willmore/github-fetchdir` (whole repo, default branch)

`https://github.com/ben-willmore/github-fetchdir/tree/testbranch/test` (subdirectory, main branch)

`https://github.com/ben-willmore/github-fetchdir/tree/aa25db658a2013f8a0004cbdbff3ff59ce3e0aaa/test` (subdirectory, specific commit)

This can be pasted from a github page that shows a directory.
  
If <dest_dir> is supplied, the fetched directory will be put there; otherwise it will be put in the current directory.

This should work on any unix system with basic tools installed (bash, sed, grep, ...), including jq and either curl or wget.

### Rate limit

Note that github has an API limit of about 60 requests per hour for unauthenticated users. `github-fetchdir` will use one API call per directory or subdirectory, so will not be able to download a directory with >59 subdirectories. `github-fetchdir -l` will tell you how many requests you have left and when your quota will reset.