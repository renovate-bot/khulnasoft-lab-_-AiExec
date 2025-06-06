#!/bin/bash
set -x

SCRIPT_DIR="$(dirname "$(realpath "$0")")"
cd "$SCRIPT_DIR/../.."

pytest src/backend/base/langflow/api/tests/integration_tests/vdb/chroma \
  src/backend/base/langflow/api/tests/integration_tests/vdb/milvus \
  src/backend/base/langflow/api/tests/integration_tests/vdb/pgvecto_rs \
  src/backend/base/langflow/api/tests/integration_tests/vdb/pgvector \
  src/backend/base/langflow/api/tests/integration_tests/vdb/qdrant \
  src/backend/base/langflow/api/tests/integration_tests/vdb/weaviate \
  src/backend/base/langflow/api/tests/integration_tests/vdb/elasticsearch \
  src/backend/base/langflow/api/tests/integration_tests/vdb/vikingdb \
  src/backend/base/langflow/api/tests/integration_tests/vdb/baidu \
  src/backend/base/langflow/api/tests/integration_tests/vdb/tcvectordb \
  src/backend/base/langflow/api/tests/integration_tests/vdb/upstash \
  src/backend/base/langflow/api/tests/integration_tests/vdb/couchbase \
  src/backend/base/langflow/api/tests/integration_tests/vdb/oceanbase \
  src/backend/base/langflow/api/tests/integration_tests/vdb/tidb_vector \
  src/backend/base/langflow/api/tests/integration_tests/vdb/huawei \
