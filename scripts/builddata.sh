#!/bin/bash
echo 'Configuring JIT variables...'
sed 's/TRAVISCOMMIT/'$TRAVIS_COMMIT'/' ./frontend/builddata.partial.rb > ./frontend/builddata.partial2.rb
sed 's/TRAVISBUILD/'$TRAVIS_BUILD_NUMBER'/' ./frontend/builddata.partial2.rb > ./frontend/inc/builddata.rb
echo 'Done!'