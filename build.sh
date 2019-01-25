VER=$1

/bin/rm -rf _book/
/bin/rm -rf node_modules/
gitbook install
gitbook build
rm -rf ../tech_talk_pages/*
cp -rf _book/* ../tech_talk_pages/
cp -rf node_modules/ ../tech_talk_pages/node_modules
cd ../tech_talk_pages
git commit -a -m "v${VER}"
git push origin gh-pages
