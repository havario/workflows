#!/usr/bin/env python3

import requests
import json
import asyncio
from datetime import datetime
from telegram import Bot

BOT_TOKEN = '7718937420:AAHpozXlpjK1cvPZvbCojQjQsQW2iiP-LwY'
CHAT_ID = '6485476975'
OWM_TOKEN = '6f5e9d518306864d1ad6801d73dbb653'
LOCATIONS = 'Chengdu'

WEATHER_URL = f'https://api.openweathermap.org/data/2.5/weather?q={LOCATIONS}&units=metric&appid={OWM_TOKEN}'

# 初始化tgbot
bot = Bot(token=BOT_TOKEN)

# 获取天气信息
def get_weather():
    try:
        response = requests.get(WEATHER_URL)
        data = response.json()
        return data
    except Exception as e:
        print(f"Failed to retrieve weather information: {str(e)}")
        return None

# 格式化天气信息
def format_weather(weather_data):
    if weather_data:
        city_name = weather_data['name']
        temperature = weather_data['main']['temp']
        weather = weather_data['weather'][0]['description']
        timestamp = weather_data['dt']
        weather_time = datetime.fromtimestamp(timestamp).strftime('%Y-%m-%d %H:%M:%S')
        message = f"城市: {city_name}\n温度: {temperature}°C\n天气: {weather}\n时间: {weather_time}"
        return message
    return "Unable to retrieve the current weather information."

# 异步发送消息
async def send_message(message):
    """"""
    try:
        await bot.send_message(chat_id=CHAT_ID, text=message)
        print("Message sent successfully.")
    except Exception as e:
        print(f"Failed to send message: {str(e)}")

if __name__ == "__main__":
    weather_data = get_weather()
    message = format_weather(weather_data)
    asyncio.run(send_message(message))
