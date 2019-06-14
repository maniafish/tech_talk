MAIN_VER=1
GIT_CNT=`git rev-list --count HEAD`
VER=${MAIN_VER}.${GIT_CNT}

git push origin master
/bin/rm -rf _book/
sed -i '' 's#https://maniafish.github.io#https://github.com/maniafish#g' README.md
sed -i '' '/目录/d' README.md
gitbook build
/bin/rm -rf ../tech_talk_pages/*
cp -rf _book/* ../tech_talk_pages/
cp -rf node_modules/ ../tech_talk_pages/node_modules
git checkout README.md
cd ../tech_talk_pages
git add .
git commit -m "v${VER}"
git push origin gh-pages
