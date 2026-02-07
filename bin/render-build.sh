#!/usr/bin/env bash
# exit on error
set -o errexit

echo "==> Installing dependencies..."
bundle install

echo "==> Building Tailwind CSS..."
bundle exec rails tailwindcss:build

echo "==> Precompiling assets..."
bundle exec rails assets:precompile
bundle exec rails assets:clean

echo "==> Preparing database..."
bundle exec rails db:prepare

echo "==> Build complete!"
