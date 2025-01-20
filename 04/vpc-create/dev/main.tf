module "myvpc" {
  source = "../modules/vpc/"
  vpc_id = "192.168.0.0/24"
  vpc_subnet = "192.168.0.0/25"

}
module "myec2" {
  source    = "../modules/ec2/"
  subnet_id = module.myvpc.subnet_id
}