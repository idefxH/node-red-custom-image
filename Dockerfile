FROM nodered/node-red:4.1.8

# Install custom nodes at image build time so they survive the emptyDir
# /data wipe on every pod restart. package.json lists additional nodes
# beyond the default Node-RED install. They are merged into the app-level
# package.json at /usr/src/node-red so they load from the image layer.
#
# Workflow:
#   1. User installs a node via the Node-RED UI → /data/package.json updated
#   2. state-syncer sidecar detects the change, commits package.json here
#   3. This Dockerfile rebuild bakes the node into the image
#   4. Renovate (or manual bump) updates the image tag in values.yaml

WORKDIR /usr/src/node-red
COPY package.json /tmp/extra-package.json

# Merge extra dependencies into the base image's package.json, then reinstall.
# A no-op when package.json has no extra dependencies (initial state).
RUN node -e "\
  const base  = require('./package.json'); \
  const extra = require('/tmp/extra-package.json'); \
  base.dependencies = {...(base.dependencies || {}), ...(extra.dependencies || {})}; \
  require('fs').writeFileSync('./package.json', JSON.stringify(base, null, 2)); \
  " && npm install --production --no-audit --no-fund

USER node-red
