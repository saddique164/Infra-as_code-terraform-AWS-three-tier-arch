# ------ root/main.tf ----------

module "networking" {
  source   = "./networking"
  vpc_cidr = local.vpc_cidr
  #   public_cidrs = ["10.123.2.0/24","10.123.4.0/24"]
  #   private_cidrs =["10.123.1.0/24","10.123.3.0/24","10.123.5.0/24"]
  security_groups  = local.security_groups
  access_ip        = var.access_ip
  max_subnets      = 20
  private_sn_count = 3
  public_sn_count  = 2
  public_cidrs     = [for i in range(2, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  private_cidrs    = [for i in range(1, 255, 2) : cidrsubnet(local.vpc_cidr, 8, i)]
  db_subnet_group  = true #for condition of creating db security groups
}

module "database" {
  source                 = "./database"
  db_storage             = 10
  db_engine_version      = "5.7.22"
  db_instance_class      = "db.t2.micro"
  dbname                 = var.dbname
  dbusername             = var.dbusername
  dbpassword             = var.dbpassword
  db_subnet_group_name   = module.networking.db_subnet_group_name[0]
  vpc_security_group_ids = module.networking.db_security_group
  db_identifier          = "mtc-db"
  skip_final_snapshot    = true
}

module "loadbalancing" {
  source                 = "./loadbalancing"
  mtc_lb_subnets         = module.networking.mtc_public_subnet_group
  mtc_lb_sg              = module.networking.public_sg
  load_balancer_type     = var.lb_type
  aws_lb_name            = var.lbname
  tg_port                = var.port
  tg_protocol            = var.protocol
  lb_healthy_threshold   = var.healthy_threshold
  lb_unhealthy_threshold = var.unhealthy_threshold
  lb_interval            = var.interval
  lb_timeout             = var.timeout
  vpc_id                 = module.networking.vpc_id
  listener_port          = 80
  listener_protocol      = "HTTP"
}

module "compute" {
  source              = "./compute"
  instance_type       = "t3.micro"
  vol_size            = 10
  public_sg           = module.networking.public_sg
  public_subnets      = module.networking.mtc_public_subnet_group
  instance_count      = 2
  public_key_path     = "/home/ubuntu/.ssh/keymtc.pub"
  key_name            = "mtckey"
  user_data_path      = "${path.root}/userdata.tpl"
  db_endpoint         = module.database.db_endpoint
  dbuser              = var.dbusername
  dbpassword          = var.dbpassword
  dbname              = var.dbname
  lb_target_group_arn = module.loadbalancing.aws_lb_target_group_arn
  tg_port             = 8000
  private_key_path     = "/home/ubuntu/.ssh/keymtc"
}