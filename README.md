## github-fetch: Fetch a file or directory from Github by pasting its URL into the command line
  
Syntax: `github-fetch <url> [<dest_dir>]`, where `<url>` is of the form:

`https://github.com/ben-willmore/github-fetch` (whole repo, default branch)

`https://github.com/ben-willmore/github-fetch/tree/testbranch/test` (subdirectory, main branch)

`https://github.com/ben-willmore/github-fetch/tree/aa25db658a2013f8a0004cbdbff3ff59ce3e0aaa/test` (subdirectory, specific commit)

`https://github.com/ben-willmore/github-fetch/blob/main/README.md` (single file, main branch)

You can get the URL by navigating to the relevant file/directory\'s page on github and then copy-pasting from the URL bar.  

If `<dest_dir>` is supplied, the fetched content will be put there; otherwise it will be put in the current directory.

This should work on any unix system with basic tools installed (bash, sed, grep, ...), including jq and either curl or wget.

### Rate limit

Note that github has an API limit of about 60 requests per hour for unauthenticated users. `github-fetchdir` will use one API call per directory or subdirectory, so it will not be able to download a directory with >59 subdirectories. No API calls are used to download a file. `github-fetchdir -l` will tell you how many requests you have left and when your quota will reset.
