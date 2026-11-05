#!/bin/bash
set -e

# Criação do usuário dedicado para o transporte de logs
psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" --dbname "$POSTGRES_DB" <<-EOSQL
    CREATE ROLE repl_user WITH REPLICATION PASSWORD 'repl_pass' LOGIN;
EOSQL

# Autorização de conexões externas exclusivas para o processo de replicação
echo "host replication repl_user all md5" >> "$PGDATA/pg_hba.conf"

# Configuração do motor para operar no quadrante PC/EC (Multi-AZ Simulator)
cat >> "$PGDATA/postgresql.conf" <<-EOF
wal_level = replica
max_wal_senders = 10
synchronous_commit = on
synchronous_standby_names = 'standby_sync'
EOF