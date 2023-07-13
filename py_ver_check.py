#!/usr/bin/python

"""Module providing Function printing python version."""
import sys

full_version = sys.version.split()[0]
version = full_version[::-1].split(".", 1)[1][::-1]

print("Python version")
print(version)
