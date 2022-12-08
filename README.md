# README


# Initial Setup

Copy the `.env.example` file into a `.env` file.

From the project directory build the app using docker:

```
docker-compose build
```

Set up the database:

```
docker compose run api rails db:setup
```

# Running the app

Start the application and its dependencies via docker:

```
docker-compose up
```

## Updating gems inside the container

This can be done with the `bin/with_builder.sh` script:
```
./bin/with_builder.sh bundle update
```
which should update the Gems in the container, without the need for rebuilding.

# CORS Allowed Origins

Add a comma separated list to the relevant enviroment settings. E.g for development in the `.env` file:

```
ALLOWED_ORIGINS=localhost:3002,localhost:3000
