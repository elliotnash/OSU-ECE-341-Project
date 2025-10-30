#! /usr/bin/env python3
import importlib.util
Import("env")  # pyright: ignore[reportUndefinedVariable]

def install_module(name):
    if importlib.util.find_spec(name) is None:
        env.Execute(f"$PYTHONEXE -m pip install {name}")  # pyright: ignore[reportUndefinedVariable]

install_module("dotenv")
