# ami_id : ami-09667f767dcab1c56

resource "aws_key_pair" "keypair" {
    key_name = "sshkey-${terraform.workspace}"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCHKJyAHkbgMDZYjbvzuLOgDMs4Pf90o2f6BFG2MbUFbiLF1RzU7OtDbeawXTSI8cU+LFQrmXcuarrGFoqypbGAOGAq0p6Xteq+X6JVaQLQmU8X5K+mIuNe2CvOBi+L1bZXPQHelOYizu3MPRUOg0jCECFO6gXEcViM+dhjS03qpuJYFne7CduFH6FtWxBVvJ2RGw0r72kjSfbnrUI4+8i/prry9/z0pcg39pw7tah8PHuVLeM8xl35IFhAevicjm6MWXEk7R0oQmrbKBVOuFStUnYHFzKd3J4gtopI99BFkIQ/nALBuifkFerbbbMJ648QYTI52RN6UpZAtWH9a7TH"
}

resource "aws_instance" "front_server" {
    ami = var.ubuntu_ami
    subnet_id = aws_subnet.public_subnet.id
    instance_type = "t2.medium"
    vpc_security_group_ids = [aws_security_group.front_server_sg.id]
    key_name = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size = 24
    }
    tags = {
        Name = format("front01-%s", terraform.workspace)
        Environment = terraform.workspace
        Role = "Front"
        Provider = "aws"
    }
}

resource "aws_instance" "app_server" {
    ami = var.ubuntu_ami
    subnet_id = aws_subnet.public_subnet.id
    instance_type = "t2.medium"
    vpc_security_group_ids = [aws_security_group.app_sg.id]
    key_name = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size = 24
    }
    tags = {
        Name = format("app01-%s", terraform.workspace)
        Environment = terraform.workspace
        Role = "App"
        Provider = "aws"
    }
}

resource "aws_instance" "bdd_server" {
    ami = var.ubuntu_ami
    subnet_id = aws_subnet.private_subnet.id
    instance_type = "t2.medium"
    vpc_security_group_ids = [aws_security_group.bdd_sg.id]
    key_name = aws_key_pair.keypair.key_name
    root_block_device {
        volume_size = 24
    }
    tags = {
        Name = format("bdd01-%s", terraform.workspace)
        Environment = terraform.workspace
        Role = "BDD"
        Provider = "aws"
    }
}