from os import environ
from datetime import datetime
from json import loads
from boto3 import client

def adjust_ecs_task_count(service_arn, desired_count):
    ecs = client("ecs")

    cluster_name = service_arn.split("/")[1]

    print(f"setando o servico {service_arn} do cluster {cluster_name} para {desired_count}", flush=True)

    ecs.update_service(cluster=cluster_name, service=service_arn, desiredCount=desired_count)

def adjust_scale(auto_scaling_group, desired_capacity):
    asg = client("autoscaling")

    print(f"setando o grupo {auto_scaling_group} para {desired_capacity}", flush=True)

    asg.update_auto_scaling_group(AutoScalingGroupName=auto_scaling_group, DesiredCapacity=desired_capacity)

def instance_sleep(instance):
    ec2 = client("ec2")

    print(f"parando a instancia {instance}", flush=True)

    ec2.stop_instances(InstanceIds=[instance])

    print(f"instancia {instance} parada", flush=True)

def instance_wake_up(instance):
    ec2 = client("ec2")

    print(f"ligando a instancia {instance}", flush=True)

    ec2.start_instances(InstanceIds=[instance])

    print(f"instancia {instance} ligada", flush=True)

def rds_sleep(rds_id):
    rds = client("rds")

    print(f"desligando o rds {rds_id}", flush=True)

    rds.stop_db_instance(DBInstanceIdentifier=rds_id)

    print(f"rds {rds_id} desligado", flush=True)

def rds_wake_up(rds_id):
    rds = client("rds")

    print(f"ligando o rds {rds_id}", flush=True)

    rds.start_db_instance(DBInstanceIdentifier=rds_id)

    print(f"rds {rds_id} ligado", flush=True)

def main(event, context):
    target_ids = loads(environ["TARGET_IDS"])

    rds_ids = loads(environ["RDS_IDS"])

    try:
        fall_asleep = loads(event["fall_asleep"])

    except KeyError:
        print("parece que fui chamado pelo sns. Desligando as maquinas.", flush=True)

        fall_asleep = True

        print(event)

        metrics = loads(event["Records"][0]["Sns"]["Message"])["Trigger"]["Metrics"]

        metric = list(filter(lambda item: item.get("MetricStat", None) is not None, metrics))[0]

        target_id = metric["MetricStat"]["Metric"]["Dimensions"][0]["value"]

        target_ids = [target_id]

        rds_ids = []

    print(f"os alvos sao: {target_ids}", flush=True)

    print(f"e {rds_ids}", flush=True)

    print(f"fall_asleep: {fall_asleep}", flush=True)

    for target_id in target_ids:
        if target_id[:11] == "arn:aws:ecs":
            if fall_asleep:
                adjust_ecs_task_count(target_id, 0)

            else:
                adjust_ecs_task_count(target_id, 1)

        elif target_id[:2] == "i-":
            if fall_asleep:
                instance_sleep(target_id)

            else:
                instance_wake_up(target_id)

        else:
            if fall_asleep:
                adjust_scale(target_id, 0)

            else:
                adjust_scale(target_id, 1)

    for rds_id in rds_ids:
        if fall_asleep:
            rds_sleep(rds_id)

        else:
            rds_wake_up(rds_id)

    print("encerrando", flush=True)