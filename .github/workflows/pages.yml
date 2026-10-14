name: Deploy web
on:
  push:
    branches: [main]
  workflow_dispatch:
permissions:
  contents: write
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      - uses: subosito/flutter-action@v2
        with:
          channel: stable
      - run: flutter create --platforms web --project-name worker_career_kit .
      - run: flutter pub get
      - run: flutter build web --release --base-href /worker-career-kit/
      - name: Publish to gh-pages
        run: |
          cd build/web
          touch .nojekyll
          git init -b gh-pages
          git config user.name "github-actions"
          git config user.email "actions@users.noreply.github.com"
          git add -A
          git commit -m "Deploy"
          git push -f "https://x-access-token:${{ secrets.GITHUB_TOKEN }}@github.com/${{ github.repository }}.git" gh-pages
