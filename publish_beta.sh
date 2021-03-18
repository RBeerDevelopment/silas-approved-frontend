read -r -p "Did you increment the version name and build number?  " yn
case $yn in
  [Yy]* )
    flutter build ios --release --no-codesign
    cd ios || exit
    fastlane beta
    ;;
  [Nn]* )
    exit
    ;;
  * )
    echo "Please answer yes or no."
    ;;
esac