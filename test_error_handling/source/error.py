#!/usr/bin/env python3

import sys
import time

print("Python script starting...")
print("This will produce some output...")
time.sleep(1)

print("Outputting multiple lines to test real-time logging:")
for i in range(5):
    print(f"  Line {i+1} of output")
    time.sleep(0.5)

print("\nNow encountering an error...")
time.sleep(1)

# Intentional error
print("ERROR: Something went wrong!")
sys.exit(1)  # Exit with error code 1
