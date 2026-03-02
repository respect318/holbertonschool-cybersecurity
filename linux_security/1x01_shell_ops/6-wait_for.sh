#!/bin/bash
until nc -z localhost 80; do
    echo "Waiting..."
    sleep 1
done
echo "Service UP!"
