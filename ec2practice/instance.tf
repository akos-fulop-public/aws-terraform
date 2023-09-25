resource "aws_instance" "app_server" {
  ami           = "ami-0f845a2bba44d24b2"
  instance_type = "t2.micro"

  tags = {
    Name = "ExampleAppServerInstance"
  }
}
