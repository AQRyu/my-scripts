#!/usr/bin/env bash

VERSIONS=(
  "maven:3.9.10"
  "mvnd:1.0.2"
  "gradle:8.14"
)

source "$HOME/.sdkman/bin/sdkman-init.sh"
if ! command -v sdk >/dev/null 2>&1; then
  echo "SDKMAN! not found. Please install it." >&2
  exit 1
fi

mkdir -p "$HOME/.sdks"

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

echo "Installing other SDKs using SDKMAN!..."
for package_version in "${VERSIONS[@]}"; do
  install_sdk "$package_version"
done
echo "Installation of other SDKs finished."

echo "Copying installed SDKs from SDKMAN! dir to $HOME/.sdks..."
if [ -z "${SDKMAN_DIR:-}" ]; then
  echo "Error: SDKMAN_DIR is not set. Cannot determine SDK installation paths." >&2
  exit 1
fi

declare -A OTHER_SDK_COPY_MAP=(
  ["maven"]="maven:3.9.10"
  ["mvnd"]="mvnd:1.0.2"
  ["gradle"]="gradle:8.14"
)

for sdk_name_short in "${!OTHER_SDK_COPY_MAP[@]}"; do
  sdkman_package_version="${OTHER_SDK_COPY_MAP[$sdk_name_short]}"
  sdkman_package="${sdkman_package_version%:*}"
  sdkman_version="${sdkman_package_version#*:}"

  source_dir="$SDKMAN_DIR/candidates/$sdkman_package/$sdkman_version"
  target_dir="$HOME/.sdks/$sdk_name_short"

  if [ -d "$source_dir" ]; then
      rm -rf "$target_dir"
    cp -r "$source_dir" "$target_dir"
    echo "Copied $source_dir to $target_dir"
  else
    echo "Warning: Source directory $source_dir not found. Skipping copy for $sdkman_package:$sdkman_version. Ensure 'sdk install $sdkman_package $sdkman_version' ran successfully." >&2
  fi
done

echo "Copying process finished."