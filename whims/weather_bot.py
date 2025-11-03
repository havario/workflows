#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
OWM_API_KEY="ce9a54e990cca7f1b768cbe1b6c919b5"
export QWEATHER_API_KEY="845db3ab74514bbea04ed168861f23f1"
export LOCATIONS="成都武侯区,成都金牛区"
export CRON_SCHEDULE="0 8 * * *"
export BOT_TOKEN="7718937420:AAHpozXlpjK1cvPZvbCojQjQsQW2iiP-LwY"
export CHAT_ID="6485476975"
"""

import os
import logging
import requests
import time
from datetime import datetime
from apscheduler.schedulers.blocking import BlockingScheduler
from telegram import Bot
from telegram.error import TelegramError
import re
from concurrent.futures import ThreadPoolExecutor

logging.basicConfig(level=logging.INFO, format='%(asctime)s - %(levelname)s - %(message)s')
logger = logging.getLogger(__name__)

# 获取环境变量
def get_environment_variable(variable_name, default_value=None):
    value = os.getenv(variable_name)
    if not value and default_value is None:
        raise ValueError(f"Required environment variable {variable_name} not set!")
    return value

open_weather_map_api_key = get_environment_variable('OWM_API_KEY')
qweather_api_key = get_environment_variable('QWEATHER_API_KEY')
locations_list = [loc.strip() for loc in get_environment_variable('LOCATIONS', 'Beijing').split(',') if loc.strip()]
cron_schedule = get_environment_variable('CRON_SCHEDULE', '0 8 * * *')  # 默认早8
bot_token = get_environment_variable('BOT_TOKEN')
chat_id = get_environment_variable('CHAT_ID')
telegram_bot = Bot(token=bot_token)

# 获取经纬度
def get_latitude_longitude(location_name):
    url = f"http://api.openweathermap.org/geo/1.0/direct?q={location_name}&limit=1&appid={open_weather_map_api_key}"
    response = requests.get(url, timeout=5).json()
    if response:
        latitude = response[0]['lat']
        longitude = response[0]['lon']
        return latitude, longitude
    if re.search(r'[\u4e00-\u9fff]', location_name):
        english_location = location_name.replace(' ', '') + ',CN'
        response = requests.get(f"http://api.openweathermap.org/geo/1.0/direct?q={english_location}&limit=1&appid={open_weather_map_api_key}", timeout=5).json()
        if response:
            latitude = response[0]['lat']
            longitude = response[0]['lon']
            return latitude, longitude
    raise ValueError(f"Failed to parse location: {location_name}")

# 获取天气数据
def get_weather_data(latitude, longitude):
    url = f"https://api.openweathermap.org/data/2.5/onecall?lat={latitude}&lon={longitude}&appid={open_weather_map_api_key}&units=metric&lang=zh_cn&exclude=minutely,hourly,alerts"
    response = requests.get(url, timeout=10).json()
    if response.get('cod') != 200:
        raise ValueError(f"OWM API error: {response.get('message')}")
    return response

# 和风天气获取当日穿衣建议
def get_dress_advice_data(location_name):
    # 经纬度转换
    latitude, longitude = get_latitude_longitude(location_name)
    url = f"https://devapi.qweather.com/v7/indices/1d?type=1&location={location_name}&key={qweather_api_key}"
    response = requests.get(url, timeout=5).json()
    if response.get('code') != '200':
        raise ValueError(f"QWeather API error: {response.get('message')}")
    daily_data = response.get('daily', [{}])[0]
    level = daily_data.get('text', '未知')
    description = daily_data.get('category', '无建议')  # brief/detail融合
    return {'level': level, 'description': description}

# 构建消息
def build_weather_message(location_name):
    try:
        latitude, longitude = get_latitude_longitude(location_name)
        weather_response = get_weather_data(latitude, longitude)
        current_weather = weather_response['current']
        temperature = current_weather['temp']
        feels_like_temperature = current_weather['feels_like']
        weather_description = current_weather['weather'][0]['description']
        humidity = current_weather['humidity']
        wind_speed = current_weather['wind_speed']
        tomorrow_weather = weather_response['daily'][1]
        tomorrow_description = tomorrow_weather['weather'][0]['description']
        tomorrow_temperature = tomorrow_weather['temp']['day']
        dress_advice = get_dress_advice_data(location_name)
        message_text = f"""📍 {location_name}

🌤️ {weather_description} (体感 {feels_like_temperature}°C)
🌡️ {temperature}°C | 湿度 {humidity}% | 风速 {wind_speed} m/s

👕 穿衣指数：{dress_advice['level']}
建议：{dress_advice['description']}

📅 预报：明天 {tomorrow_description}，{tomorrow_temperature}°C"""
        return message_text
    except Exception as error:
        logger.error(f"Failed to build message for {location_name}: {error}")
        return f"📍 {location_name}\n❌ 天气获取失败，请检查API key"

# 构建所有消息
def build_all_messages():
    with ThreadPoolExecutor(max_workers=5) as executor:
        messages = list(executor.map(build_weather_message, locations_list))
    return messages

# 推送通知
def push_weather_notification(attempt_number=1, max_attempts=3):
    try:
        start_time = datetime.now()
        logger.info(f"Starting push at: {start_time}")
        messages_list = build_all_messages()
        full_message = '\n\n---\n\n'.join(messages_list)
        telegram_bot.send_message(chat_id=chat_id, text=full_message, parse_mode='Markdown')
        logger.info(f"Push successful: {len(messages_list)} locations, duration {datetime.now() - start_time}")
    except TelegramError as telegram_error:
        logger.error(f"Telegram push failed: {telegram_error}")
        if attempt_number < max_attempts:
            time.sleep(2 ** (attempt_number - 1))
            push_weather_notification(attempt_number + 1, max_attempts)
        else:
            raise
    except Exception as general_error:
        logger.error(f"Unexpected error in push: {general_error}")
        raise

if __name__ == "__main__":
    scheduler = BlockingScheduler()
    cron_parts = cron_schedule.split()
    scheduler.add_job(push_weather_notification, 'cron', minute=cron_parts[0], hour=cron_parts[1] if len(cron_parts) > 1 else None, day=cron_parts[2] if len(cron_parts) > 2 else None, month=cron_parts[3] if len(cron_parts) > 3 else None, day_of_week=cron_parts[4] if len(cron_parts) > 4 else None)
    logger.info(f"Weather pusher started, schedule: {cron_schedule}, locations: {locations_list}")
    scheduler.start()
