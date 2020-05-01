printenv | sed 's/^\(.*\)$/export \1/g' > /scripts/.env;

cron -f
