#!/bin/bash

# Parse the arguments.
DOCROOT=$2/$3/build-$1
PARAMS=$4

# Run PHP CodeSniffer
phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,js $PARAMS $DOCROOT/sites/all/modules/custom > $DOCROOT/php_cs_modules.txt
phpcs --standard=Drupal --extensions=php,module,inc,install,test,profile,theme,css,js $PARAMS $DOCROOT/sites/all/themes/custom > $DOCROOT/php_cs_themes.txt

echo "Code Sniffer check is done."
