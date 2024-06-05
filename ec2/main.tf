provider "aws" {
    region = "ap-northeast-2"
}

data "aws_vpc" "sample_vpc" {
  id = "vpc-0cda761c39c3dd695"
}

data "aws_internet_gateway" "sample_igw" {
  internet_gateway_id = "igw-0a9665983e688ac9e"
}

data "aws_iam_instance_profile" "sample_ec2_profile" {
  name = "sample_ec2_profile"
}