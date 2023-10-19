#!/bin/bash

# Initialize variables
TARGET_URL=""
ORIGINS=(
    "http://valid-origin.com"
    "http://another-valid-origin.com"
    "http://invalid-origin.com"
)

# Function to display usage instructions
usage() {
    echo "Usage: $0 -u <target_url>"
    exit 1
}

# Parse command line options
while getopts "u:" opt; do
    case "$opt" in
        u)
            TARGET_URL="$OPTARG"
            ;;
        *)
            usage
            ;;
    esac
done

# Check if the target URL is provided
if [ -z "$TARGET_URL" ]; then
    usage
fi

# Flag to track if any CORS origin validation failure occurs
vulnerable=false

# Loop through the list of origins and send HTTP requests
for ORIGIN in "${ORIGINS[@]}"; do
    # Send a GET request with a specific origin
    echo "Testing origin: $ORIGIN"
    RESPONSE_HEADERS=$(curl -s -I -H "Origin: $ORIGIN" "$TARGET_URL")

    # Check the HTTP response code to identify CORS failure
    HTTP_RESPONSE=$(echo "$RESPONSE_HEADERS" | grep -i -E "^HTTP" | tail -n 1)
    if [[ $HTTP_RESPONSE == *4* || $HTTP_RESPONSE == *5* ]]; then
        echo "CORS Origin Validation Failed: $HTTP_RESPONSE"
        vulnerable=true
    fi

    # Display the response headers
    echo "Response Headers:"
    echo "$RESPONSE_HEADERS"
done

if [ "$vulnerable" = true ]; then
    echo "Target is vulnerable"
else
    echo "Target is not vulnerable"
fi
