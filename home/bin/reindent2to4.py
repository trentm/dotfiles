#!/usr/bin/env python

"""Change indent of given file(s) from 2-space to 4-space."""

import os
import sys
import codecs


#---- the main thang

def reindent2to4(path):
    print "Reindenting '%s'..." % path,
    f = codecs.open(path, 'r', 'utf8')
    before = f.read()
    f.close()
    lines = before.splitlines(True)
    after = []
    for line in lines:
        if not line.startswith('  '):
            after.append(line)
            continue
        i = 0
        while i < len(line) and line[i] == ' ':
            i += 1
        indent = line[:i]
        new_indent = (len(indent) / 2 * 4 * ' ') + (len(indent) % 2 * ' ')
        after.append(new_indent + line[i:])
    after = ''.join(after)
    if before == after:
        print "no change."
    else:
        f = codecs.open(path, 'w', 'utf8')
        f.write(after)
        f.close()
        print "updated."



#---- mainline

def main(argv):
    for path in argv[1:]:
        reindent2to4(path)

if __name__ == '__main__':
    sys.exit(main(sys.argv))
