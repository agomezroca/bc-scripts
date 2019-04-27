#!/bin/bash

MAGE_HOME="/var/www/html"

echo " *** cache:clean ***"

${MAGE_HOME}/bin/magento cache:clean

echo " *** cache:flush ***"

${MAGE_HOME}/bin/magento cache:flush
