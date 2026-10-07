#!/bin/sh
set -eu
# Mounted Railway volumes initially belong to root.
mkdir -p /app/uploads
chown -R -h bookish:bookish /app/uploads
exec su-exec bookish java -jar /app/app.jar
