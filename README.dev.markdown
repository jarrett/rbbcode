# Developing This Gem

To start a container with this gem's root folder mounted:

    docker-compose up

To get a shell when docker-compose is running:

    docker exec -it rbbcode_ruby_1 /bin/bash

To release a new version:

    gem build rbbcode.gemspec
    gem signin
    # Replace x.x.x with the latest version number.
    gem push rbbcode-x.x.x.gem