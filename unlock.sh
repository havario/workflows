#!/usr/bin/env bash
#
# Description: check the status of your ip on various geo-restricted services.
#
# Copyright (c) 2025 honeok <honeok@duck.com>
#
# Licensed under the GNU General Public License, version 2 only.
# This program is distributed WITHOUT ANY WARRANTY.
# See <https://www.gnu.org/licenses/old-licenses/gpl-2.0.html>.

# 当前脚本版本号
readonly VERSION='v0.0.1 (2025.04.20)'

red='\033[91m'
green='\033[92m'
yellow='\033[93m'
purple='\033[95m'
cyan='\033[96m'
white='\033[0m'
_red() { echo -e "$red$*$white"; }
_green() { echo -e "$green$*$white"; }
_yellow() { echo -e "$yellow$*$white"; }
_purple() { echo -e "$purple$*$white"; }
_cyan() { echo -e "$cyan$*$white"; }

# 各变量默认值
UA_BROWSER="Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/125.0.0.0 Safari/537.36"
UA_SEC_CH_UA='"Google Chrome";v="125", "Chromium";v="125", "Not.A/Brand";v="24"'

show_ScriptTitle() {
    echo "-------------------- A unlock.sh Script By honeok --------------------"
    echo " $(_yellow 'Version')            : $(_green "$VERSION") $(_red "\xF0\x9F\x94\x93")"
    echo " $(_cyan 'bash <(curl -sL https://github.com/honeok/cross/raw/master/unlock.sh)')"
}



# Netflix
MediaUnlockTest_Netflix() {
    # 乐高忍者
    local result1=$(curl -A "$UA_BROWSER" "$CURL_DEFAULT_OPTS" -fsL 'http://www.netflix.com/title/81280792' -w %{http_code} -o /dev/null -H 'host: www.netflix.com' -H 'accept-language: en-US,en;q=0.9' -H "sec-ch-ua: ${UA_SEC_CH_UA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document')
    # 绝命毒师
    local result2=$(curl -A "$UA_BROWSER" "$CURL_DEFAULT_OPTS" -fsL 'http://www.netflix.com/title/70143836' -w %{http_code} -o /dev/null -H 'host: www.netflix.com' -H 'accept-language: en-US,en;q=0.9' -H "sec-ch-ua: ${UA_SEC_CH_UA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document')

    if [ "$result1" == '000' ] || [ "$result2" == '000' ]; then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}Failed (Network Connection)${Font_Suffix}\n"
        return
    fi
    if [ "$result1" == '404' ] && [ "$result2" == '404' ]; then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Yellow}Originals Only${Font_Suffix}\n"
        return
    fi
    if [ "$result1" == '403' ] || [ "$result2" == '403' ]; then
        echo -n -e "\r Netflix:\t\t\t\t${Font_Red}No${Font_Suffix}\n"
        return
    fi
    if [ "$result1" == '200' ] || [ "$result2" == '200' ]; then
        local tmpresult=$(curl -A "$UA_BROWSER" "$CURL_DEFAULT_OPTS" -sL 'https://www.netflix.com/' -H 'accept-language: en-US,en;q=0.9' -H "sec-ch-ua: ${UA_SEC_CH_UA}" -H 'sec-ch-ua-mobile: ?0' -H 'sec-ch-ua-platform: "Windows"' -H 'sec-fetch-site: none' -H 'sec-fetch-mode: navigate' -H 'sec-fetch-user: ?1' -H 'sec-fetch-dest: document')
        local region=$(echo "$tmpresult" | grep -oP '"id":"\K[^"]+' | grep -E '^[A-Z]{2}$' | head -n 1)
        echo -n -e "\r Netflix:\t\t\t\t${Font_Green}Yes (Region: ${region})${Font_Suffix}\n"
        return
    fi

    echo -n -e "\r Netflix:\t\t\t\t\t${Font_Red}Failed (Error: ${result1}_${result2})${Font_Suffix}\n"
}

