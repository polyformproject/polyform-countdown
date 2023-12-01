#!/bin/sh
set -e

effective_date="$1"
new_license="$2"

usage() {
cat <<USAGE
Fill out the PolyForm Countdown license grant template
and write the result to standard output.

Usage: <date> (<SPDX ID> | <file>)

Examples:
  $0 $(date --iso-8601 -d "+1 year") ./new-license.txt > dist/COUNTDOWN
  $0 \$(date --iso-8601 -d "+3 years") Apache-2.0 >> release/LICENSE.md
USAGE
}

if [ -z "$effective_date" ] || [ -z "$new_license" ]; then
  usage
  exit 1
fi

fail() {
  printf "Error: %s\n" "$1" >/dev/stderr
  exit 1
}

# Check the new license text before printing the grant.
if [ -f "$new_license" ]; then
  spdx_url=""
else
  spdx_url="https://spdx.org/licenses/$new_license.txt"

  # Warn about popular license templates.
  case "$new_license" in
    BSD-2-Clause|\
    BSD-3-Clause|\
    ISC|\
    MIT)
      fail "$new_license has fill-in-the-blanks. Copy it to a file, fill in the blanks, and provide the file as final argument to this script."
      ;;
  esac

  # Make sure spdx.org has the license text.
  if ! curl --silent --fail "$spdx_url" >/dev/null; then
    fail "Error: No license found with SPDX ID \"$new_license\"!" >/dev/stderr
  fi
fi

# Fill in the effect date and wrap lines.
sed "s/{start date}/$effective_date/; /{Copy the scheduled license terms here.}/d" form.md | fmt -w60

# Append the license text.
printf "\`\`\`\n"
if [ -n "$spdx_url" ]; then
  curl --silent "$spdx_url"
else
  cat "$new_license"
fi
printf "\n\`\`\`\n"
