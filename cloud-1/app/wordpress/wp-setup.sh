#!/bin/sh
# Installs WordPress and creates users. Idempotent: safe to run many times.
set -eu

if ! wp core is-installed 2>/dev/null; then
    echo "Installing WordPress..."
    wp core install \
        --url="https://${DOMAIN_NAME}" \
        --title="${WP_TITLE}" \
        --admin_user="${WP_SUPER_USER}" \
        --admin_password="${WP_SUPER_PASSWORD}" \
        --admin_email="${WP_SUPER_EMAIL}" \
        --skip-email
else
    echo "WordPress already installed, skipping."
fi

if ! wp user get "${WP_USER}" >/dev/null 2>&1; then
    echo "Creating user ${WP_USER}..."
    wp user create "${WP_USER}" "${WP_USER_EMAIL}" \
        --role=author \
        --user_pass="${WP_USER_PASSWORD}"
else
    echo "User ${WP_USER} already exists, skipping."
fi
