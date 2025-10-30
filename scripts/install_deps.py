#! /usr/bin/env python3
Import("env")  # pyright: ignore[reportUndefinedVariable]

env.Execute("$PYTHONEXE -m pip install dotenv")  # pyright: ignore[reportUndefinedVariable]
