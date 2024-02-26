#!/bin/bash
set -e

# Execute rake task
echo "Running rake i18n:export_pseudo_i18n..."
bundle exec rake i18n:export_pseudo_i18n

# Then execute the CMD
exec "$@"
