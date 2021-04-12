#!/usr/bin/env bash

tmp_dir=$(mktemp -d package.XXXXX)
pip3 install --target ${tmp_dir} -r requirements.txt > /dev/null
pushd ${tmp_dir} > /dev/null
zip -rq ../probe.zip .
popd > /dev/null
zip -gq probe.zip probe.py 
rm -r ${tmp_dir}
pkg_name_json=$(jq -n --arg pkg "probe.zip" '{package: $pkg}')
echo ${pkg_name_json}