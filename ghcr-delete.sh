#!/bin/bash
# Deletes ALL versions of a GHCR container package (tagged + untagged).
# Requires: GH_TOKEN env var with a token that has `packages:write`/`delete:packages` scope.
# Usage: OWNER=nareshbaburoddam PACKAGE_NAME=nextcloud-php-dev GH_TOKEN=xxx ./delete-all-ghcr-versions.sh

set -e

if [ -z "$GH_TOKEN" ] || [ -z "$OWNER" ] || [ -z "$PACKAGE_NAME" ]; then
  echo "❌ Please set GH_TOKEN, OWNER, and PACKAGE_NAME environment variables first."
  exit 1
fi

echo "🔍 Fetching all versions for $PACKAGE_NAME (owner: $OWNER) ..."
VERSIONS=$(curl -s -H "Authorization: Bearer $GH_TOKEN" \
  -H "Accept: application/vnd.github+json" \
  "https://api.github.com/users/$OWNER/packages/container/$PACKAGE_NAME/versions?per_page=100")

COUNT=$(echo "$VERSIONS" | jq 'length')
echo "📦 Total versions found: $COUNT"

if [ "$COUNT" -eq 0 ]; then
  echo "✅ Nothing to delete."
  exit 0
fi

IDS=$(echo "$VERSIONS" | jq -r '.[].id')

for id in $IDS; do
  echo "🗑️  Deleting version id: $id ..."
  curl -s -X DELETE -H "Authorization: Bearer $GH_TOKEN" \
    -H "Accept: application/vnd.github+json" \
    "https://api.github.com/users/$OWNER/packages/container/$PACKAGE_NAME/versions/$id"
  echo "✅ Deleted: $id"
done

echo "🎉 All versions of $PACKAGE_NAME deleted."
