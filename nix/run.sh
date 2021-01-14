#! /usr/bin/env bash
SCRIPTPATH="$( cd "$(dirname "$0")" >/dev/null 2>&1 ; pwd -P )" # https://stackoverflow.com/questions/4774054/reliable-way-for-a-bash-script-to-get-the-full-path-to-itself
export MICRO_CONFIG_HOME="$SCRIPTPATH"/../microhome

pushd -- "$SCRIPTPATH"/..
mkdir -p -- "$MICRO_CONFIG_HOME"/plug/selfexec
cp -r -- selfexec.lua execwrapper.sh help "$MICRO_CONFIG_HOME"/plug/selfexec
popd

# https://github.com/zyedidia/micro/issues/1990#issuecomment-760094426 Support installing plugins from a local directory
$(nix-build -v "$SCRIPTPATH"/default.nix -A p.micro --no-out-link)/bin/micro -debug "$@"
