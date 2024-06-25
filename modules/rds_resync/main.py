from os import environ, getenv

from time import sleep, time

from boto3 import client, Session

from botocore.errorfactory import ClientError

def create_remote_session(role_arn):
    sts = client("sts")

    role_name = role_arn.split("/")[-1:][0]

    response = sts.assume_role(RoleArn=role_arn, RoleSessionName=role_name)

    session = Session(
        aws_access_key_id=response["Credentials"]["AccessKeyId"],
        aws_secret_access_key=response["Credentials"]["SecretAccessKey"],
        aws_session_token=response["Credentials"]["SessionToken"],
    )

    return session.client("rds"), session.region_name

def create_snapshot(snapshot_name, instance_identifier, destination_account_id):
    rds = client("rds")

    rds.create_db_snapshot(
        DBSnapshotIdentifier=snapshot_name,
        DBInstanceIdentifier=instance_identifier
    )

    while rds.describe_db_snapshots(DBSnapshotIdentifier=snapshot_name)["DBSnapshots"][0]["Status"] != "available" :
        print("Snapshot nao esta pronto. Esperando...", flush=True)

        sleep(10)

    rds.modify_db_snapshot_attribute(
        DBSnapshotIdentifier=snapshot_name,
        AttributeName="restore",
        ValuesToAdd=[destination_account_id]
    )

def rename_old_bd(rds, instance_identifier):
    rds.modify_db_instance(DBInstanceIdentifier=instance_identifier, ApplyImmediately=True, NewDBInstanceIdentifier=f"{instance_identifier}-old")

    while True:
        try:
            rds.describe_db_instances(DBInstanceIdentifier=f"{instance_identifier}-old")

            break

        except ClientError as error:
            if error.response["Error"]["Code"] == "DBInstanceNotFound":
                print("Nao terminei de renomear. aguardando...", flush=True)

                sleep(10)

            else:
                raise error

def restore_snapshot(rds, region, source_account_id, snapshot_name, instance_identifier):
    dados_do_rds = rds.describe_db_instances(DBInstanceIdentifier=f"{instance_identifier}-old")

    if dados_do_rds["DBInstances"][0]["StorageType"] == "io1":
        rds.restore_db_instance_from_db_snapshot(
            DBInstanceIdentifier=instance_identifier,
            DBSnapshotIdentifier=f"arn:aws:rds:{region}:{source_account_id}:snapshot:{snapshot_name}",
            DBSubnetGroupName=dados_do_rds["DBInstances"][0]["DBSubnetGroup"]["DBSubnetGroupName"],
            VpcSecurityGroupIds=[dado["VpcSecurityGroupId"] for dado in dados_do_rds["DBInstances"][0]["VpcSecurityGroups"]],
            DBInstanceClass=dados_do_rds["DBInstances"][0]["DBInstanceClass"],
            StorageType=dados_do_rds["DBInstances"][0]["StorageType"],
            Iops=dados_do_rds["DBInstances"][0]["Iops"],
            AllocatedStorage=dados_do_rds["DBInstances"][0]["AllocatedStorage"],
            DBParameterGroupName=dados_do_rds["DBInstances"][0]["DBParameterGroups"][0]["DBParameterGroupName"],
            OptionGroupName=dados_do_rds["DBInstances"][0]["OptionGroupMemberships"][0]["OptionGroupName"],
            Port=dados_do_rds["DBInstances"][0]["Endpoint"]["Port"]
        )

    else:
        rds.restore_db_instance_from_db_snapshot(
            DBInstanceIdentifier=instance_identifier,
            DBSnapshotIdentifier=f"arn:aws:rds:{region}:{source_account_id}:snapshot:{snapshot_name}",
            DBSubnetGroupName=dados_do_rds["DBInstances"][0]["DBSubnetGroup"]["DBSubnetGroupName"],
            VpcSecurityGroupIds=[dado["VpcSecurityGroupId"] for dado in dados_do_rds["DBInstances"][0]["VpcSecurityGroups"]],
            DBInstanceClass=dados_do_rds["DBInstances"][0]["DBInstanceClass"],
            StorageType=dados_do_rds["DBInstances"][0]["StorageType"],
            Iops=dados_do_rds["DBInstances"][0]["Iops"],
            StorageThroughput= dados_do_rds["DBInstances"][0]["StorageThroughput"],
            AllocatedStorage=dados_do_rds["DBInstances"][0]["AllocatedStorage"],
            DBParameterGroupName=dados_do_rds["DBInstances"][0]["DBParameterGroups"][0]["DBParameterGroupName"],
            OptionGroupName=dados_do_rds["DBInstances"][0]["OptionGroupMemberships"][0]["OptionGroupName"],
            Port=dados_do_rds["DBInstances"][0]["Endpoint"]["Port"]
        )

def clear_old_instance(rds, instance_identifier):
    rds.delete_db_instance(
        DBInstanceIdentifier=instance_identifier,
        SkipFinalSnapshot=True,
        DeleteAutomatedBackups=True
    )

def main(event, context):
    source_account_id = environ["SOURCE_ACCOUNT_ID"]

    destination_account_id = environ["DESTINATION_ACCOUNT_ID"]

    source_instance_identifier = environ["SOURCE_INSTANCE_ID"]

    target_instance_identifier = environ["TARGET_INSTANCE_ID"]

    role_arn = environ["TARGET_ACCOUNT_ROLE_ARN"]

    snapshot_name = getenv("SNAPSHOT_NAME") or f"{source_instance_identifier}-{int(time())}"

    print("Criando sessao remota", flush=True)

    rds, region = create_remote_session(role_arn)

    print("Criando snapshot", flush=True)

    create_snapshot(snapshot_name, source_instance_identifier, destination_account_id)

    print("Renomeando bd antigo", flush=True)

    rename_old_bd(rds, target_instance_identifier)

    print("Restaurando snapshot", flush=True)

    restore_snapshot(rds, region, source_account_id, snapshot_name, target_instance_identifier)

    print("Retirando a instancia antiga", flush=True)

    clear_old_instance(rds, f"{target_instance_identifier}-old")