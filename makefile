all:
	/bin/rm -rf _book/
	/bin/rm -rf node_modules/
	gitbook install
	gitbook build
