set dotenv-load

# Start the demo
up *args="":
    docker compose up --detach --build {{args}}

# Stop the demo
down *args="":
    docker compose down {{args}}

# Stop the demo and destroy the data
down-all:
    docker compose down -v

# Configure and register the device to the cloud (requires go-c8y-cli and c8y-tedge extension)
bootstrap *args="":
    c8y tedge bootstrap-container tedge "$DEVICE_ID" {{args}}

# Start a shell
shell *args='sh':
    docker compose exec tedge {{args}}

# Install python virtual environment
venv:
  [ -d .venv ] || python3 -m venv .venv
  ./.venv/bin/pip3 install -r tests/requirements.txt

# Run tests
test *args='':
  ./.venv/bin/python3 -m robot.run --outputdir output {{args}} tests

# Build linux package
build:
    ./ci/build.sh

# Build packages used in tests
build-test-packages:
    nfpm package -f tests/testdata/nfpm-example.yaml -p rpm --target tests/testdata

# Cleanup device and all it's dependencies
cleanup DEVICE_ID $CI="true":
    echo "Removing device and child devices (including certificates)"
    c8y devicemanagement certificates list -n --tenant "$(c8y currenttenant get --select name --output csv)" --filter "name eq {{DEVICE_ID}}" --pageSize 2000 | c8y devicemanagement certificates delete --tenant "$(c8y currenttenant get --select name --output csv)"
    c8y inventory find -n --owner "device_{{DEVICE_ID}}" -p 100 | c8y inventory delete
    c8y users delete -n --id "device_{{DEVICE_ID}}" --tenant "$(c8y currenttenant get --select name --output csv)" --silentStatusCodes 404 --silentExit