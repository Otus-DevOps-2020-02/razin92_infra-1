#!/usr/bin/python

import os
import sys
import json

script, action = sys.argv

def read_static():
    with open('inventory.json') as source:
        inventory = json.load(source)
        return json.dumps(inventory)


if __name__ == '__main__':
    if action == '--list':
        print(read_static())
