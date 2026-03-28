## วิธีรันโปรเจกต์ (Terraform)

### 1. ตั้งค่า AWS CLI
```
aws configure
```

จากนั้นใส่

* AWS Access Key
* AWS Secret Key
* Region (เช่น ap-southeast-1)

#### อย่าลืม create key pairs ใน aws

### 2. Initialize และตรวจสอบ
```
terraform init
terraform plan
```

### 3. Deploy ระบบ
```
terraform apply 
```
พิมพ์ 
```
yes
```

### 4. เข้าใช้งาน
นำ URL จาก output ไปเปิดใน browser เช่น:
ตัวอย่าง
```
http://<public_ip>/sports_rental_system/customer/frontend/login.html
```

### 6. ข้อมูลสำหรับเข้าใช้งาน (Test Account)
#### เจ้าหน้าที่เช่า-คืนอุปกรณ์ gmail: rattana@nu.ac.th password: rattana_jaidee
#### ผู้ดูแลคลัง gmail: sumet@nu.ac.th password: sumet_jaidee
#### อธิการบดี gmail: somchai@nu.ac.th password: hashed_pw004
#### ผู้บริหาร gmail: Winai@nu.ac.th password: winai_jaidee
