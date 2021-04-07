#!/usr/bin/env bash

tmp_dir=$(mktemp -d package.XXXXX)
cp -r venv/lib/python3*/site-packages/* ${tmp_dir}
cp -r config/ ${tmp_dir}
cp probe.py ${tmp_dir}
pushd ${tmp_dir} > /dev/null
zip -rq probe.zip *
popd > /dev/null
mv ${tmp_dir}/probe.zip .
rm -r ${tmp_dir}
pkg_name_json=$(jq -n --arg pkg "probe.zip" '{package: $pkg}')
echo ${pkg_name_json}