"""Inspect private fingerprint CSV structure; no measurements or accuracy claim."""
import argparse
import csv
import io
import json
import math
from collections import Counter
from pathlib import Path

HEADER = ['x', 'y', 'RSSI A', 'RSSI B', 'RSSI C']


def inspect(stream, expected):
    reader = csv.reader(stream)
    if next(reader, None) != HEADER:
        raise ValueError('header must be x,y,RSSI A,RSSI B,RSSI C')
    rows = []
    for line, row in enumerate(reader, 2):
        if len(row) != 5 or any(not value.strip() for value in row):
            raise ValueError(f'row {line}: five nonempty fields required')
        try:
            values = tuple(float(value) for value in row)
        except ValueError as exc:
            raise ValueError(f'row {line}: numeric fields required') from exc
        if not all(math.isfinite(value) for value in values):
            raise ValueError(f'row {line}: finite fields required')
        rows.append(values)
    if len(rows) != expected:
        raise ValueError(f'expected {expected} rows, found {len(rows)}')
    counts = Counter(row[:2] for row in rows)
    return {'rows': len(rows), 'duplicate_coordinate_groups': sum(n > 1 for n in counts.values())}, set(counts)


def self_test():
    valid = ','.join(HEADER) + '\n1,2,-10,-20,-30\n3,4,-11,-21,-31\n'
    assert inspect(io.StringIO(valid), 2)[0]['rows'] == 2
    invalid = [valid.replace('x,y,', 'x,x,', 1), valid + '\n',
               valid.replace('-10', 'NaN'), valid.replace('-10', 'inf'),
               valid.replace('-10', 'word'), valid.replace('-10', ''),
               valid.replace('-30', '-30,99')]
    for bad in invalid:
        try:
            inspect(io.StringIO(bad), 2)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid fixture accepted')
    try:
        inspect(io.StringIO(valid), 40)
    except ValueError:
        pass
    else:
        raise AssertionError('row mismatch accepted')
    print('CSV_SELF_TEST=PASS (1 valid, 8 invalid artificial fixtures)')


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--self-test', action='store_true')
    parser.add_argument('--train', type=Path)
    parser.add_argument('--test', type=Path)
    parser.add_argument('--train-rows', type=int, default=40)
    parser.add_argument('--test-rows', type=int, default=16)
    args = parser.parse_args()
    if args.self_test:
        self_test()
    if args.train or args.test:
        if not (args.train and args.test):
            parser.error('--train and --test are required together')
        results = []
        for filename, count in [(args.train, args.train_rows), (args.test, args.test_rows)]:
            with filename.open(encoding='utf-8-sig', newline='') as stream:
                results.append(inspect(stream, count))
        print(json.dumps({'train': results[0][0], 'test': results[1][0],
                          'shared_coordinate_pairs': len(results[0][1] & results[1][1]),
                          'scope': 'schema only; coordinate overlap is not proof of leakage'}))
    elif not args.self_test:
        parser.error('choose --self-test or provide --train and --test')


if __name__ == '__main__':
    main()
