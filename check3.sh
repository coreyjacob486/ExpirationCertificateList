#!/bin/bash

# Check if domains.txt exists
if [ ! -f domains.txt ]; then
    echo "File domains.txt not found!"
    exit 1
fi

# Output file
output_file="cert_expiration_dates.txt"

# Clear the output file if it exists
> "$output_file"

# Timeout setting (in seconds)
timeout_duration=3

# Read each domain from the file and retrieve the SSL certificate expiration date
while IFS= read -r domain; do
    # Fetch the certificate expiration date using OpenSSL with timeout
    expiration_date=$(timeout "$timeout_duration" bash -c "echo | openssl s_client -connect \"$domain:443\" -servername \"$domain\" 2>/dev/null | openssl x509 -noout -enddate")

    # Check if the command succeeded
    if [ $? -eq 0 ] && [ -n "$expiration_date" ]; then
        # Format the output by stripping "notAfter=" from the expiration date
        expiration_date_formatted=${expiration_date#*=}
        echo "$domain: $expiration_date_formatted" >> "$output_file"
    else
        echo "$domain: Unable to retrieve expiration date (timeout or error)" >> "$output_file"
    fi
done < domains.txt

echo "Expiration dates have been saved to $output_file"
