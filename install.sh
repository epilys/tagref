#!/usr/bin/env sh

# Usage examples:
#   ./install.sh
#   VERSION=x.y.z ./install.sh
#   PREFIX=/usr/local/bin ./install.sh

# We wrap everything in curly braces to prevent the shell from executing only
# a prefix of the script if the download is interrupted.
{
  # Where the binary will be installed
  DESTINATION="${PREFIX:-/usr/local/bin}/tagref"

  # Which version to download
  RELEASE="v${VERSION:-1.1.0}"

  # Determine which binary to download.
  FILENAME=''
  if uname -a | grep -qi 'x86_64.*GNU/Linux'; then
    echo 'x86_64 GNU/Linux detected.'
    FILENAME=tagref-x86_64-unknown-linux-gnu
  fi
  if uname -a | grep -qi 'Darwin.*x86_64'; then
    echo 'macOS detected.'
    FILENAME=tagref-x86_64-apple-darwin
  fi

  # Fail if there is no pre-built binary for this platform.
  if [ -z "$FILENAME" ]; then
    echo 'Unfortunately, there is no pre-built binary for this platform.' 1>&2
    exit 1
  fi

  # Find a temporary location for the binary.
  TEMPFILE=$(mktemp /tmp/tagref.XXXXXXXX)

  # Download the binary.
  if ! curl "https://github.com/stepchowfun/tagref/releases/download/$RELEASE/$FILENAME" -o "$TEMPFILE" -LSf; then
    echo 'There was an error downloading the binary.' 1>&2
    rm "$TEMPFILE"
    exit 1
  fi

  # Make it executable.
  if ! chmod a+rx "$TEMPFILE"; then
    echo 'There was an error setting the permissions for the binary.' 1>&2
    rm "$TEMPFILE"
    exit 1
  fi

  # Install it at the requested destination.
  mv "$TEMPFILE" "$DESTINATION" 2> /dev/null || sudo mv "$TEMPFILE" "$DESTINATION" < /dev/tty

  # Let the user know it worked.
  echo 'Tagref is now installed.'
}
