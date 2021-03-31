#!/usr/bin/env bash

# User-provided configuration must always be respected.
#
# Therefore, this script must only derives Airflow AIRFLOW__ variables from other variables
# when the user did not provide their own configuration.


case "$1" in
  webserver)
    sleep 30
    ;;
  scheduler)
    sleep 30
    ;;
  worker)
    sleep 30
    ;;
  flower)
    sleep 30
    ;;
esac


TRY_LOOP="20"

# Global defaults and back-compat
: "${AIRFLOW_HOME:="/usr/local/airflow"}"

# Load DAGs examples (default: Yes)
if [[ -z "$AIRFLOW__CORE__LOAD_EXAMPLES" && "${LOAD_EX:=n}" == n ]]; then
  AIRFLOW__CORE__LOAD_EXAMPLES=False
fi

export \
  AIRFLOW_HOME \
  AIRFLOW__CORE__LOAD_EXAMPLES

wait_for_port() {
  local name="$1" host="$2" port="$3"
  local j=0
  while ! nc -z "$host" "$port" >/dev/null 2>&1 < /dev/null; do
    j=$((j+1))
    if [ $j -ge $TRY_LOOP ]; then
      echo >&2 "$(date) - $host:$port still not reachable, giving up"
      exit 1
    fi
    echo "$(date) - waiting for $name... $j/$TRY_LOOP"
    sleep 5
  done
}

# Other executors than SequentialExecutor drive the need for an SQL database, here PostgreSQL is used
if [ "$AIRFLOW__CORE__EXECUTOR" != "SequentialExecutor" ]; then
  # Derive useful variables from the AIRFLOW__ variables provided explicitly by the user
  POSTGRES_ENDPOINT=$(echo -n "$AIRFLOW__CORE__SQL_ALCHEMY_CONN" | cut -d '/' -f3 | sed -e 's,.*@,,')
  POSTGRES_HOST=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f1)
  POSTGRES_PORT=$(echo -n "$POSTGRES_ENDPOINT" | cut -d ':' -f2)
  wait_for_port "Postgres" $POSTGRES_HOST $POSTGRES_PORT
fi


# Install custom python package if requirements.txt is present
if [ -e "${AIRFLOW_HOME}/dag-repo/requirements.txt" ]; then
    echo "Installing from requirements.txt"
    $(command -v pip) install --user -r "${AIRFLOW_HOME}/dag-repo/requirements.txt"
fi


case "$1" in
  init)
    airflow db init && \
    airflow users create \
        --role Admin \
        --username $AIRFLOW_ADMIN_USER \
        --firstname Admin \
        --lastname Admin \
        --email $AIRFLOW_ADMIN_EMAIL \
        --password $AIRFLOW_ADMIN_PWD
    ;;
  webserver)
    airflow db check && airflow db upgrade
    exec airflow webserver
    ;;
  scheduler)
    # Give the webserver time to run initdb.
    sleep 30
    exec airflow "$@"
    ;;
  worker)
    # Give the webserver time to run initdb.
    sleep 30
    exec airflow celery "$@"
    ;;
  flower)
    sleep 30
    exec celery "$@"
    ;;
  version)
    exec airflow "$@"
    ;;
  *)
    # The command is something like bash, not an airflow subcommand. Just run it in the right environment.
    exec "$@"
    ;;
esac
