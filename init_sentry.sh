#!/bin/bash

curl -sL https://sentry.io/get-cli/ | bash

export SENTRY_DSN="https://60b54799df74ddab5585ba77f35f37ab@o4508080703864832.ingest.de.sentry.io/4508363861655632"
sentry-cli update
eval "$(sentry-cli bash-hook)"