#!/usr/bin/env python
import sys
data = open(sys.argv[1], 'rb').read()
decoded = data.decode('utf-8')
print(decoded)
