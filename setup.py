#!/usr/bin/env python

from distutils.core import setup

setup(name='splink_demos',
      version='1.0',
      description='Splink Demos Utility Functions',
      author='moj-analytical-services',
      author_email='robinlinacre@hotmail.com',
      url='https://github.com/moj-analytical-services/splink_demos',
      packages=['utility_functions', 'data', 'aws_glue', 'jars', 'snippets', 'ubuntu_spark_submit'],
     )