#!/usr/bin/env python3

# Work around mbcs bug in distutils.
# http://bugs.python.org/issue10945
import codecs
try:
    codecs.lookup('mbcs')
except LookupError:
    ascii = codecs.lookup('ascii')
    func = lambda name, enc=ascii: {True: enc}.get(name=='mbcs')
    codecs.register(func)
    
from distutils.core import setup

setup(
    name='XCPSetup',
    version='0.1',
    description='XCP Programming and Configuration Utilities',
    author='Doug Brunner, Guy Cardwell',
    author_email='dbrunner@ebus.com, gcardwel@hgmelectronics.com',
    url='http://bitbucket.org/xcptools/xcpsetup',
    packages=['xcpsetup', 'xcpsetup.cmdline', 'xcpsetup.comm', 'xcpsetup.plugins', 'xcpsetup.pyclibrary', 'xcpsetup.util'],
    package_dir={'xcpsetup': 'src'}
)
