#!/usr/bin/env bash

VERSIONS=(
  "java:21.0.2-graalce"
  "java:17.0.15-tem"
  "java:11.0.27-tem"
  "java:8.0.452-tem"
)

source "$HOME/.sdkman/bin/sdkman-init.sh"
if ! command -v sdk >/dev/null 2>&1; then
  echo "SDKMAN! not found. Please install it."
  exit 1
fi

mkdir -p "$HOME/.jdks"

install_sdk() {
  local package_version="$1"
  local package="${package_version%:*}"
  local version="${package_version#*:}"

  if ! sdk current "$package" "$version" &>/dev/null; then
    sdk install "$package" "$version"
  else
    echo "$package version $version is already installed."
  fi
}

echo "Installing Java SDKs using SDKMAN!..."
for package_version in "${VERSIONS[@]}"; do
  install_sdk "$package_version"
done

echo "Installation of Java SDKs finished."

declare -A JAVA_COPY_MAP=(
  ["21"]="21.0.2-graalce"
  ["17"]="17.0.15-tem"
  ["11"]="11.0.27-tem"
  ["8"]="8.0.452-tem"
)

if [ -z "${SDKMAN_DIR:-}" ]; then
  echo "Error: SDKMAN_DIR is not set. Cannot determine SDK installation paths."
  exit 1
fi

for java_version_short in "${!JAVA_COPY_MAP[@]}"; do
  sdkman_version="${JAVA_COPY_MAP[$java_version_short]}"
  source_dir="$SDKMAN_DIR/candidates/java/$sdkman_version"
  target_dir="$HOME/.jdks/$java_version_short"

  if [ -d "$source_dir" ]; then
    rm -rf "$target_dir"
    cp -r "$source_dir" "$target_dir"
    echo "Copied $source_dir to $target_dir"
  else
    echo "Warning: Source directory $source_dir not found. Skipping copy for Java $java_version_short."
  fi
done

echo "Copying process finished."