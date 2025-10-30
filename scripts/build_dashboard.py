#! /usr/bin/env python3
import os
Import("env")  # pyright: ignore[reportUndefinedVariable]

# Build the dashboard with pnpm
env.Execute(f"cd dashboard && pnpm build")  # pyright: ignore[reportUndefinedVariable]
