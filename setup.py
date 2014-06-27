__version__ = '0.1.0-dev'

import os
import sys

py_version = sys.version_info[:2]

if py_version < (2, 6):
    raise RuntimeError(
        'On Python 2, Corvus requires Python 2.6 or later')
elif (3, 0) < py_version < (3, 2):
    raise RuntimeError(
        'On Python 3, Corvus requires Python 3.2 or later')

from setuptools import setup, find_packages
here = os.path.abspath(os.path.dirname(__file__))

CLASSIFIERS = [
    'Development Status :: 3 - Alpha',
    'Environment :: Console',
    'Intended Audience :: Developers',
    'License :: OSI Approved :: BSD License',
    'Natural Language :: English',
    'Operating System :: POSIX',
    'Programming Language :: Python :: 2',
    'Programming Language :: Python :: 2.6',
    'Programming Language :: Python :: 2.7',
    'Programming Language :: Python :: 3',
    'Programming Language :: Python :: 3.2',
    'Programming Language :: Python :: 3.3',
    'Programming Language :: Python :: 3.4',
    'Topic :: System :: Emulators',
    'Topic :: System :: Hardware'
    ]

setup(
    name = 'corvus',
    version = __version__,
    license = 'License :: OSI Approved :: BSD License',
    url = 'http://github.com/mnaberez/corvus',
    description = "Corvus flat-cable hard drive experiments",
    classifiers = CLASSIFIERS,
    author = "Mike Naberezny",
    author_email = "mike@naberezny.com",
    maintainer = "Mike Naberezny",
    maintainer_email = "mike@naberezny.com",
    packages = find_packages(),
    install_requires = [],
    tests_require = [],
    include_package_data = True,
    zip_safe = False,
    namespace_packages = ['corvus'],
    test_suite = 'corvus.tests',
    entry_points={
        'console_scripts': [
            'corvus = corvus.console:main',
        ],
    },
)
