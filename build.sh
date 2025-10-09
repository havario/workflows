#!/usr/bin/env bash
#
# Description: This script is used to replace the unpkg and bytedance static resource public library address.
#
# Copyright (c) 2025 honeok <i@honeok.com>
# SPDX-License-Identifier: Apache-2.0

set -eEux

sed -i 's#https://unpkg.com/xterm@5.3.0/css/xterm.css#https://fastly.jsdelivr.net/npm/xterm@5.3.0/css/xterm.css#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/xterm@5.3.0/lib/xterm.js#https://fastly.jsdelivr.net/npm/xterm@5.3.0/lib/xterm.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-fit@0.10.0/lib/addon-fit.js#https://fastly.jsdelivr.net/npm/@xterm/addon-fit@0.10.0/lib/addon-fit.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-web-links@0.11.0/lib/addon-web-links.js#https://fastly.jsdelivr.net/npm/@xterm/addon-web-links@0.11.0/lib/addon-web-links.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-attach@0.11.0/lib/addon-attach.js#https://fastly.jsdelivr.net/npm/@xterm/addon-attach@0.11.0/lib/addon-attach.js#g' resource/template/dashboard-default/terminal.html
