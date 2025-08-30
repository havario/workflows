#!/usr/bin/env sh -ex
#
# Description:
#
# Copyright (c) 2025 honeok <i@honeok.com>
#
# SPDX-License-Identifier: Apache-2.0

# common
sed -i 's#https://unpkg.com/jquery@3.7.1/dist/jquery.min.js#https://cdnjs.cloudflare.com/ajax/libs/jquery/3.7.1/jquery.min.js#g' resource/template/common/footer.html
sed -i 's#https://unpkg.com/semantic-ui@2.4.0/dist/semantic.min.js#https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.0/semantic.min.js#g' resource/template/common/footer.html
sed -i 's#https://unpkg.com/vue@2.6.14/dist/vue.min.js#https://cdnjs.cloudflare.com/ajax/libs/vue/2.6.14/vue.min.js#g' resource/template/common/footer.html

sed -i 's#https://unpkg.com/semantic-ui@2.4.0/dist/semantic.min.css#https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.0/semantic.min.css#g' resource/template/common/header.html
sed -i 's#https://unpkg.com/font-logos@0.17.0/assets/font-logos.css#https://registry.npmmirror.com/font-logos/0.17.0/files/assets/font-logos.css#g' resource/template/common/header.html

# dashboard-default
sed -i 's#https://unpkg.com/mdui@2/mdui.css#https://cdnjs.cloudflare.com/ajax/libs/mdui/2.1.4/mdui.min.css#g' resource/template/dashboard-default/file.html
sed -i 's#https://unpkg.com/mdui@2/mdui.global.js#https://cdnjs.cloudflare.com/ajax/libs/mdui/2.1.4/mdui.global.min.js#g' resource/template/dashboard-default/file.html

sed -i 's#https://unpkg.com/clipboard@2.0.11/dist/clipboard.min.js#https://cdnjs.cloudflare.com/ajax/libs/clipboard.js/2.0.11/clipboard.min.js#g' resource/template/dashboard-default/server.html

sed -i 's#https://unpkg.com/xterm@5.3.0/css/xterm.css#https://registry.npmmirror.com/xterm/5.3.0/files/css/xterm.css#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/xterm@5.3.0/lib/xterm.js#https://registry.npmmirror.com/xterm/5.3.0/files/lib/xterm.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-fit@0.10.0/lib/addon-fit.js#https://registry.npmmirror.com/@xterm/addon-fit/0.10.0/files/lib/addon-fit.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-web-links@0.11.0/lib/addon-web-links.js#https://registry.npmmirror.com/@xterm/addon-web-links/0.11.0/files/lib/addon-web-links.js#g' resource/template/dashboard-default/terminal.html
sed -i 's#https://unpkg.com/@xterm/addon-attach@0.11.0/lib/addon-attach.js#https://registry.npmmirror.com/@xterm/addon-attach/0.11.0/files/lib/addon-attach.js#g' resource/template/dashboard-default/terminal.html

# theme-angel-kanade
sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/jquery/3.6.0/jquery.min.js#https://cdnjs.cloudflare.com/ajax/libs/jquery/3.6.0/jquery.min.js#g' resource/template/theme-angel-kanade/footer.html
sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/semantic-ui/2.4.1/semantic.min.js#https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.js#g' resource/template/theme-angel-kanade/footer.html
sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/vue/2.6.14/vue.min.js#https://cdnjs.cloudflare.com/ajax/libs/vue/2.6.14/vue.min.js#g' resource/template/theme-angel-kanade/footer.html

sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/semantic-ui/2.4.1/semantic.min.css#https://cdnjs.cloudflare.com/ajax/libs/semantic-ui/2.4.1/semantic.min.css#g' resource/template/theme-angel-kanade/header.html
sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/font-logos/0.17/font-logos.min.css#https://registry.npmmirror.com/font-logos/0.17.0/files/assets/font-logos.css#g' resource/template/theme-angel-kanade/header.html
sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/bootstrap-icons/1.8.1/font/bootstrap-icons.min.css#https://cdnjs.cloudflare.com/ajax/libs/bootstrap-icons/1.8.1/font/bootstrap-icons.css#g' resource/template/theme-angel-kanade/header.html

sed -i 's#https://lf6-cdn-tos.bytecdntp.com/cdn/expire-1-y/flag-icon-css/4.1.5/flags/1x1/#https://cdnjs.cloudflare.com/ajax/libs/flag-icon-css/4.1.5/flags/1x1/#g' resource/template/theme-angel-kanade/home.html

# theme-angel-kanade
