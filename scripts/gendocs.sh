echo 'Generating documentation...'
rdoc --main README.md
echo 'Uploading to GitHub...'
cd doc
git init
git checkout -b gh-pages
git add -A
git -c user.name='Travis CI' -c user.email='wordman05@gmail.com' commit -m init
git push -f -q https://ARMmaster17:$GITHUB_API_KEY@github.com/PrincetonRidgeHA/HomeWeb-gh-pages gh-pages &2>/dev/null
cd ..