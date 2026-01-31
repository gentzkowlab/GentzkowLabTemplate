#!/bin/bash

echo "Shell script starting..."
echo "This will produce some output..."
sleep 1

echo ""
echo "Outputting multiple lines to test real-time logging:"
for i in {1..5}; do
    echo "  Line $i of output"
    sleep 0.5
done

echo ""
echo "Now encountering an error..."
sleep 1

# Intentional error
echo "ERROR: Something went wrong in shell!" >&2
exit 1
