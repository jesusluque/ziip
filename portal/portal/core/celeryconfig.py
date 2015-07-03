# -*- coding: utf-8 -*-

from __future__ import absolute_import
import os
import sys
from celery import Celery
from celery.task import task
from django.conf import settings

sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/../..')
sys.path.append(os.path.dirname(os.path.abspath(__file__)) + '/..')

# set the default Django settings module for the 'celery' program.
os.environ.setdefault('DJANGO_SETTINGS_MODULE', 'settings')

from celery.schedules import crontab

from portal.settings import *
BROKER_URL = 'amqp://guest@localhost//'
celery = Celery('tasks',  broker=BROKER_URL)