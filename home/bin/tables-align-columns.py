#!/usr/bin/env python

"""
Align(*) columns in Markdown tables.

Usage:
    tables-align-columns.py foo.md   # Writes updated file to stdout.

Notes:
- If the `-r` option is given, `align(*)`ing of columns currently treats the
  *last* column specially. It uses a "min-width", set to the width of the header
  cell or its underline. This allows tables that a last column that contains a
  sometimes-long description to not force all other cells in that column to be
  that full width.

Limitations:
- Can't handle tables where cells have a pipe.
- Currently the underline row is hardcoded to use `| ---- |`-spacing. It
  doesn't support `|------|`-spacing.
"""

# TODO:
# - doctests

__version__ = "1.3.0"

import argparse
import codecs
import re
import sys
from collections import defaultdict
from pprint import pprint

p = print
def e(*args, **kwargs):
    kwargs['file'] = sys.stderr
    p(*args, **kwargs)

#---- internal support stuff

def tables_align_columns(text, relaxed_last_column=False):
    def _table_sub(match):
        head, underline, body = match.groups()

        data_rows = [
            [cell.strip() for cell in head.strip().strip('|').split('|')],
        ]
        for line in body.strip('\n').split('\n'):
            data_rows.append([cell.strip() for cell in line.strip().strip('|').split('|')])

        width_from_col_idx = defaultdict(int)
        for data_row in data_rows:
            for col_idx, cell in enumerate(data_row):
                width_from_col_idx[col_idx] = max(
                    2, width_from_col_idx[col_idx], len(cell))
        if relaxed_last_column:
            # Note: Could have a "smart" option that only bothers with
            # this if the last row is particularly wide, if the full
            # table width is >77 cols or whatever.
            width_from_col_idx[len(data_rows[0]) - 1] = max(
                len(data_rows[0][-1]), # the column label
                # The underline. Need to `-2` because this script assumes
                # underline style with spaces between the pipes: `| ---- |`,
                # rather than `|-----|`.
                len(underline.rstrip('\n').strip('|').split('|')[-1]) - 2
            )

        # Determine aligns for columns.
        ucells = [cell.strip() for cell in underline.strip('| \t\n').split('|')]
        align_from_col_idx = {}
        for col_idx, cell in enumerate(ucells):
            if cell[0] == ':' and cell[-1] == ':':
                align_from_col_idx[col_idx] = 'center'
            elif cell[0] == ':':
                align_from_col_idx[col_idx] = 'left'
            elif cell[-1] == ':':
                align_from_col_idx[col_idx] = 'right'
            else:
                align_from_col_idx[col_idx] = None

        table = []
        for data_row in data_rows:
            row = []
            #e('align_from_col_idx:', align_from_col_idx)
            #e('data_row:', data_row)
            for col_idx, cell in enumerate(data_row):
                width = width_from_col_idx[col_idx]
                try:
                    align = align_from_col_idx[col_idx]
                except KeyError:
                    # Limitation: We hit a table row where a cell has a
                    # literal `|` in it. We can't currently handle that, so
                    # lets just skip this table.
                    e('tables-align-columns: warning: skipping a table '
                      'with literal `|`: %r' % match.group(0))
                    return match.group(0)
                if align == 'center':
                    space = width - len(cell)
                    left = space / 2
                    right = space - left
                    row.append(' '*left + cell + ' '*right)
                elif align == 'right':
                    row.append('%%%ds' % width % cell)
                else:
                    row.append('%%-%ds' % width % cell)
            table.append(row)

        underline = []
        for col_idx, cell in enumerate(data_rows[0]):
            width = width_from_col_idx[col_idx]
            align = align_from_col_idx[col_idx]
            if align == 'center':
                underline.append(':' + '-'*(width-2) + ':')
            elif align == 'right':
                underline.append('-'*(width-1) + ':')
            elif align == 'left':
                underline.append(':' + '-'*(width-1))
            else:
                underline.append('-'*width)
        table[1:1] = [underline]
        #e(pformat(table, width=200))

        table_str = '\n'.join(('| ' + ' | '.join(r) + ' |') for r in table)
        return table_str + '\n'

    less_than_tab = 3
    table_re = re.compile(r'''
            (?:(?<=\n\n)|\A\n?)             # leading blank line

            ^[ ]{0,%d}                      # allowed whitespace
            (.*[|].*)  \n                   # $1: header row (at least one pipe)

            ^[ ]{0,%d}                      # allowed whitespace
            (                               # $2: underline row
                # underline row with leading bar
                (?:  \|\ *:?-+:?\ *  )+  \|?  \n
                |
                # or, underline row without leading bar
                (?:  \ *:?-+:?\ *\|  )+  (?:  \ *:?-+:?\ *  )?  \n
            )

            (                               # $3: data rows
                (?:
                    ^[ ]{0,%d}(?!\ )         # ensure line begins with 0 to less_than_tab spaces
                    .*\|.*  \n
                )+
            )
        ''' % (less_than_tab, less_than_tab, less_than_tab), re.M | re.X)
    return table_re.sub(_table_sub, text)


#---- mainline

def main(argv):
    parser = argparse.ArgumentParser(allow_abbrev=False)
    parser.add_argument('--in-place', '-I', action='store_true', help='Edit the given FILES *in-place*.')
    parser.add_argument('-r', action='store_true', help='Relaxed width on last column.')
    parser.add_argument('paths', nargs='*', metavar='PATHS', help='Paths to .md files to process.')
    args = parser.parse_args()

    for path in args.paths:
        if path == '-':
            if args.in_place:
                raise RuntimeError('cannot use --in-place option with "-" (stdin) path')
            orig = sys.stdin.read()
        else:
            orig = codecs.open(path, 'rb', 'utf8').read()
        text = tables_align_columns(orig, relaxed_last_column=args.r)
        if args.in_place:
            if text == orig:
                print(f'tables-align-columns: no change in "{path}"')
            else:
                codecs.open(path, 'wb', 'utf8').write(text)
                print(f'tables-align-columns: wrote "{path}"')

        else:
            sys.stdout.write(text)

if __name__ == "__main__":
    sys.exit( main(sys.argv) )
