#/bin/sh

echo 'This script will overwrite your LOCAL database with the contents of the STAGING database.'
echo
read -p 'Do you want to continue? (y/N) ' -n 1 -r
echo
if [[ $REPLY =~ ^[Yy]$ ]]
then
  data_dir='tmp/heroku-data'

  rm -rf "$data_dir"
  mkdir -p "$data_dir"
  ls "$data_dir"
  echo 'Getting pg database'
  heroku pg:backups:capture --app editor-api-staging
  heroku pg:backups:download --app editor-api-staging --output "$data_dir/latest.dump"
  echo 'starting a container to run DB commands'
  docker compose run api bin/db-sync/load-local-db.sh
  echo 'Database sync complete'
else
  echo 'Database sync cancelled'
fi
