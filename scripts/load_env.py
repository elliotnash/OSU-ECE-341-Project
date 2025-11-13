#! /usr/bin/env python3
import os
from dotenv import load_dotenv
Import("env")  # pyright: ignore[reportUndefinedVariable]

# Load environment variables from .env file
load_dotenv()

# Add environment variables to cpp macros
env.Append(CPPDEFINES=[  # pyright: ignore[reportUndefinedVariable]
    ("WIFI_SSID", env.StringifyMacro(os.getenv("WIFI_SSID"))),  # pyright: ignore[reportUndefinedVariable]
    ("WIFI_PASSWORD", env.StringifyMacro(os.getenv("WIFI_PASSWORD"))),  # pyright: ignore[reportUndefinedVariable]
    ("DISTANCE_WINDOW_SIZE", os.getenv("DISTANCE_WINDOW_SIZE")),  # pyright: ignore[reportUndefinedVariable]
    ("SENSOR_REFRESH_INTERVAL", os.getenv("SENSOR_REFRESH_INTERVAL")),  # pyright: ignore[reportUndefinedVariable]
])
