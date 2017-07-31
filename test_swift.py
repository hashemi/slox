#!/usr/bin/env python3

from os.path import dirname, realpath
import sys
from test import JAVA_SUITES, INTERPRETERS, run_suites, run_suite
import test

test.REPO_DIR = dirname(realpath(__file__))

SWIFT_SUITES = JAVA_SUITES

def java_to_swift_interpreter(interpreter):
	if interpreter.language == 'java':
		# interpreter.language = 'swift'
		interpreter.args = ['.build/debug/slox']
	return interpreter

INTERPRETERS = {name: java_to_swift_interpreter(interpreter) for (name, interpreter) in INTERPRETERS.items()}

def main():
  if len(sys.argv) < 2 or len(sys.argv) > 3:
    print('Usage: test.py <interpreter> [filter]')
    sys.exit(1)

  if len(sys.argv) == 3:
    filter_path = sys.argv[2]

  if sys.argv[1] == 'all':
    run_suites(sorted(INTERPRETERS.keys()))
  elif sys.argv[1] == 'c':
    run_suites(C_SUITES)
  elif sys.argv[1] == 'swift':
    run_suites(SWIFT_SUITES)
  elif sys.argv[1] not in INTERPRETERS:
    print('Unknown interpreter "{}"'.format(sys.argv[1]))
    sys.exit(1)

  else:
    if not run_suite(sys.argv[1]):
      sys.exit(1)

if __name__ == '__main__':
  main()