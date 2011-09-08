#!/bin/bash
cp -f src/preamble.js lib/index.js
coffee -p src/index.coffee >> lib/index.js
