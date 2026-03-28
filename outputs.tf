output "app_public_url" {
  value       = "http://${aws_instance.web_sport_customer.public_ip}"
  description = "เปิด URL นี้ใน Browser (ถ้าหน้าแรกอยู่ในโฟลเดอร์ ให้เติม /customer หรือโฟลเดอร์อื่นตามหลัง)"
}

