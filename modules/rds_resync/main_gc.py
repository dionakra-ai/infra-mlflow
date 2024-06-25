from os import environ, getenv

from boto3 import client

def match_name(name, identifier):
    try:
        db_identifier, timestamp = name.split("-")

        if db_identifier != identifier:
            return False

    except ValueError:
        return False
    
    try:
        int(timestamp)

    except ValueError:
        return False

    return True

def main(event, context):
    print("iniciando a limpesa...", flush=True)

    source_instance_identifier = environ["SOURCE_INSTANCE_ID"]

    snapshot_name = getenv("SNAPSHOT_NAME") or source_instance_identifier

    rds = client("rds")

    print("listando snapshots", flush=True)

    snapshots = rds.describe_db_snapshots(
        DBInstanceIdentifier=source_instance_identifier,
        SnapshotType="manual"
    )

    for snapshot in snapshots["DBSnapshots"]:
        snapshot_identifier = snapshot["DBSnapshotIdentifier"]

        if snapshot_identifier == snapshot_name or match_name(snapshot_identifier, source_instance_identifier):
            print(f"removendo o snapshot: {snapshot_identifier}", flush=True)

            rds.delete_db_snapshot(DBSnapshotIdentifier=snapshot_identifier)

    print("terminado", flush=True)