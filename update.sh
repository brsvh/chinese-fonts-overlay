#!/usr/bin/env bash

echo "\""0-unstable-$(date +%Y-%m-%d)"\"" > version.nix

shas="$(pwd)/shas.nix"
fonts="$(pwd)/*Fonts.nix"

wd="$(mktemp --tmpdir -d tsangertype-fonts-XXX)"

cd "$wd";

cleanup() {
    rm -rf "$wd"
}

trap cleanup ERR EXIT

printf '{\n' > $shas

for font in $(grep -hoP '(?<== ").*?(?=")' $fonts | sed 's/;$//')
do
    curl -LO "http://tsanger.cn/download/$font.ttf"
    checksum=$(sha256sum "$font.ttf" | awk '{print $1}')
    echo "  \"$font\" = \"$checksum\";" >> $shas
done

printf '}\n' >> $shas
