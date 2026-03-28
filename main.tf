provider "aws" {
  region = var.aws_region
}

resource "tls_private_key" "example" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

resource "aws_key_pair" "generated_key" {
  key_name   = var.key_name
  public_key = tls_private_key.example.public_key_openssh

  lifecycle {
    ignore_changes = [public_key]
  }
}

resource "local_file" "private_key" {
  content         = tls_private_key.example.private_key_pem
  filename        = "${path.module}/${var.key_name}.pem"
  file_permission = "0400"
}

resource "aws_security_group" "app_sg" {
  name_prefix = "web-sport-sg"

  ingress {
    from_port   = 22
    to_port     = 22
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_instance" "web_sport_customer" {
  ami                    = "ami-0ed0867532b47cc2c"
  instance_type          = var.instance_type
  key_name               = var.key_name
  vpc_security_group_ids = [aws_security_group.app_sg.id]

  user_data = <<-EOF
              #!/bin/bash
              exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
              export DEBIAN_FRONTEND=noninteractive

              # 1. ติดตั้ง Extensions
              sudo apt-get update -y
              sudo apt-get install -y apache2 mysql-server php libapache2-mod-php php-mysql php-gd php-mbstring php-xml git

              # 2. ตั้งค่า MySQL 
              sudo systemctl start mysql
              sudo mysql -e "CREATE DATABASE IF NOT EXISTS sports_rental_system;"
              sudo mysql -e "CREATE USER IF NOT EXISTS 'admin'@'localhost' IDENTIFIED BY 'password123';"
              sudo mysql -e "GRANT ALL PRIVILEGES ON sports_rental_system.* TO 'admin'@'localhost';"
              sudo mysql -e "SET GLOBAL sql_mode = 'NO_ENGINE_SUBSTITUTION';"
              sudo mysql -e "FLUSH PRIVILEGES;"

              # 3. Clone และวางไฟล์
              cd /home/ubuntu
              sudo rm -rf web_sport_customer
              git clone https://github.com/waonpimol/web_sport_customer.git
              sudo mysql sports_rental_system < /home/ubuntu/web_sport_customer/sports_rental_system.sql

              sudo rm -rf /var/www/html/*
              sudo cp -a /home/ubuntu/web_sport_customer/. /var/www/html/

              # 4. สร้างไฟล์ database.php ไว้ที่จุดสูงสุด (Root)
              sudo cat <<EOT > /var/www/html/database.php
              <?php
              \$conn = new mysqli("localhost", "admin", "password123", "sports_rental_system");
              \$conn->set_charset("utf8mb4");
              if (\$conn->connect_error) {
                  die(json_encode(["success" => false, "error" => "DB Connection Failed"]));
              }
              ?>
              EOT

              # 5. สร้างโฟลเดอร์ sports_rental_system 
              sudo mkdir -p /var/www/html/sports_rental_system
              sudo cp -a /home/ubuntu/web_sport_customer/. /var/www/html/sports_rental_system/
              
              sudo cp /var/www/html/database.php /var/www/html/sports_rental_system/database.php

              # 6. สร้าง Symbolic Link เพื่อรองรับทุก Path
              cd /var/www/html
              sudo rm -f sports_rental_system SPORTS_RENTAL_SYSTEM
              sudo ln -s . sports_rental_system
              sudo ln -s . SPORTS_RENTAL_SYSTEM

              # 7. จัดการสิทธิ์
              sudo chown -R www-data:www-data /var/www/html
              sudo find /var/www/html -type d -exec chmod 755 {} \;
              sudo find /var/www/html -type f -exec chmod 644 {} \;
              
              # 8. Restart
              sudo phpenmod mysqli gd mbstring
              sudo systemctl restart apache2
              EOF

  user_data_replace_on_change = true
}
