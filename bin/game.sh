#!/bin/bash
file=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
ruby ${file}/../src/game.rb
