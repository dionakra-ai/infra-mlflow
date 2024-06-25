resource "aws_db_subnet_group" "rds" {
    name       = "subnetgroup-rds${var.identifier}"
    subnet_ids = var.subnet_ids

    tags = merge(
        {
            Name = "subnetgroup_rds${var.identifier}"
        },
        var.tags
    )
}


resource "aws_db_instance" "rds" {
    db_name               = var.db_name
    identifier            = var.identifier
    username              = var.user
    password              = var.password
    port                  = var.port
    engine                = var.engine #oracle
    engine_version        = var.engine_version
    character_set_name    = var.charset_name
    instance_class        = var.instance_class
    allocated_storage     = var.allocated_storage
    max_allocated_storage = var.max_allocated_storage
    allow_major_version_upgrade = true
    vpc_security_group_ids = [aws_security_group.sg_rds.id]
    db_subnet_group_name = aws_db_subnet_group.rds.name
    availability_zone    = var.availability_zone
    multi_az                    = var.multi_az
    license_model               = var.license_model # tem que botar a espelunca da licensa do oracle
    storage_type                = var.storage_type # gp2. ve se as alternativas saem em conta
    backup_retention_period     = var.backup_retention_period
    backup_window               = var.backup_window
    final_snapshot_identifier   = var.final_snapshot_identifier
    skip_final_snapshot         = var.skip_final_snapshot
    delete_automated_backups    = var.delete_automated_backups
    deletion_protection         = var.deletion_protection
    iops                        = var.iops
    monitoring_interval         = var.monitoring_interval
    performance_insights_enabled = var.performance_insights_enabled
    #TODO ver esses caras. tanto o que fazem como a necessidade de iam para eles

    # enabled_cloudwatch_logs_exports       = var.enabled_cloudwatch_logs_exports

    # performance_insights_enabled          = var.performance_insights_enabled
    # performance_insights_kms_key_id       = var.performance_insights_enabled ? var.performance_insights_kms_key_id : null
    # performance_insights_retention_period = var.performance_insights_enabled ? var.performance_insights_retention_period : null

    # monitoring_interval = var.monitoring_interval
    # monitoring_role_arn = var.monitoring_role_arn
  lifecycle {
    ignore_changes = [
      backup_retention_period,
      backup_window,
      auto_minor_version_upgrade,
      copy_tags_to_snapshot,
      max_allocated_storage,
      monitoring_interval,
      performance_insights_enabled,
      allocated_storage,
      engine_version,
      apply_immediately,
      iops
    ]
  }
    tags = merge(
       
        var.tags
    )
}




# https://github.com/cloudposse/terraform-aws-rds


resource "aws_security_group" "sg_rds" {
 
  name        = "sg_${var.identifier}_rds"
  description = "Allow Cluster inbound traffic"
  vpc_id      = var.vpc_id
  revoke_rules_on_delete = true


  

  egress {
    from_port        = 0
    to_port          = 0
    protocol         = "-1"
    cidr_blocks      = ["0.0.0.0/0"]
    ipv6_cidr_blocks = ["::/0"]
  }
  



     tags = merge(
    
        var.tags
    )
   lifecycle {
    create_before_destroy = false
  }
}
resource "aws_security_group_rule" "ingress_rules" {
  
  type              = "ingress"
  from_port         = var.port
  to_port           = var.port
  protocol          = "tcp"
  cidr_blocks       = var.rules
  security_group_id = aws_security_group.sg_rds.id 

}
