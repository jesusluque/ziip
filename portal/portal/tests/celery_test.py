# -*- coding: utf-8 -*-
#!/usr/bin/env python
import os
import sys

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')
os.environ['DJANGO_SETTINGS_MODULE'] = 'portal.settings'

from portal.core.celery_tasks import *


prueba.apply_async(args=[], queue=QUEUE_DEFAULT)
