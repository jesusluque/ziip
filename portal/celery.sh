celery worker -E --concurrency=4 --app=portal.core.celery_tasks --loglevel=info --workdir=./ --config=portal.core.celeryconfig

