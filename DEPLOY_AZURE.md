# 🚀 Hướng dẫn Deploy lên Azure - Chi tiết từng bước

## 📋 Chuẩn bị trước khi deploy

### 1️⃣ Tài khoản Azure Student
- Đăng ký tại: https://azure.microsoft.com/free/students/
- Verify bằng email sinh viên (.edu hoặc email trường)
- Nhận $100 credit + free services

### 2️⃣ Cài đặt Azure CLI
```bash
brew install azure-cli
az login
```

---

## 🗄️ BƯỚC 1: Deploy Database (Azure MySQL)

### 1.1. Tạo Resource Group
```bash
az group create \
  --name rg-itss-ecommerce \
  --location southeastasia
```

### 1.2. Tạo MySQL Server
```bash
az mysql flexible-server create \
  --resource-group rg-itss-ecommerce \
  --name mysql-itss-ecommerce \
  --location southeastasia \
  --admin-user adminuser \
  --admin-password "YourSecurePassword123!" \
  --sku-name Standard_B1ms \
  --tier Burstable \
  --storage-size 32 \
  --version 8.0 \
  --public-access 0.0.0.0
```

### 1.3. Tạo Database
```bash
az mysql flexible-server db create \
  --resource-group rg-itss-ecommerce \
  --server-name mysql-itss-ecommerce \
  --database-name aims_database
```

### 1.4. Import dữ liệu
```bash
# Lấy connection string
az mysql flexible-server show-connection-string \
  --server-name mysql-itss-ecommerce \
  --database-name aims_database

# Import file SQL
mysql -h mysql-itss-ecommerce.mysql.database.azure.com \
  -u adminuser \
  -p \
  aims_database < backend/AIMS_database.sql
```

---

## 🔧 BƯỚC 2: Chuẩn bị Backend

### 2.1. Tạo file application-prod.yml
Tạo file mới: `backend/src/main/resources/application-prod.yml`

```yaml
server:
  port: 8080

spring:
  application:
    name: Project_ITSS
  datasource:
    url: jdbc:mysql://mysql-itss-ecommerce.mysql.database.azure.com:3306/aims_database?useSSL=true&requireSSL=true&serverTimezone=UTC
    username: adminuser
    password: ${MYSQL_PASSWORD}
    driver-class-name: com.mysql.cj.jdbc.Driver
  jpa:
    hibernate:
      ddl-auto: none
    show-sql: false
    properties:
      hibernate:
        dialect: org.hibernate.dialect.MySQLDialect

jwt:
  secret: ${JWT_SECRET}
  expiration: 86400000
```

### 2.2. Build JAR file
```bash
cd backend
export JAVA_HOME="/opt/homebrew/opt/openjdk@21"
export PATH="$JAVA_HOME/bin:$PATH"
./mvnw clean package -DskipTests
```

JAR file sẽ ở: `backend/target/Project_ITSS-0.0.1-SNAPSHOT.jar`

---

## ☁️ BƯỚC 3: Deploy Backend lên Azure App Service

### 3.1. Tạo App Service Plan (FREE tier)
```bash
az appservice plan create \
  --name plan-itss-backend \
  --resource-group rg-itss-ecommerce \
  --location southeastasia \
  --sku F1 \
  --is-linux
```

### 3.2. Tạo Web App
```bash
az webapp create \
  --resource-group rg-itss-ecommerce \
  --plan plan-itss-backend \
  --name itss-ecommerce-api \
  --runtime "JAVA:21-java21"
```

### 3.3. Configure App Settings
```bash
az webapp config appsettings set \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api \
  --settings \
    SPRING_PROFILES_ACTIVE=prod \
    MYSQL_PASSWORD="YourSecurePassword123!" \
    JWT_SECRET="your-super-secret-jwt-key-minimum-32-characters-long"
```

### 3.4. Deploy JAR
```bash
cd backend
az webapp deploy \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api \
  --src-path target/Project_ITSS-0.0.1-SNAPSHOT.jar \
  --type jar
```

### 3.5. Kiểm tra
Backend URL: `https://itss-ecommerce-api.azurewebsites.net`

Test:
```bash
curl https://itss-ecommerce-api.azurewebsites.net/api/health
```

---

## 🌐 BƯỚC 4: Deploy Frontend lên Azure Static Web Apps

### 4.1. Cập nhật API URL trong frontend
Sửa file: `frontend/src/config/api.ts`

```typescript
const API_BASE_URL = import.meta.env.PROD 
  ? 'https://itss-ecommerce-api.azurewebsites.net/api'
  : 'http://localhost:8080/api';

export default API_BASE_URL;
```

### 4.2. Build frontend
```bash
cd frontend
npm run build
```

Folder build sẽ ở: `frontend/dist`

### 4.3. Tạo Static Web App
```bash
az staticwebapp create \
  --name itss-ecommerce-web \
  --resource-group rg-itss-ecommerce \
  --location eastasia \
  --sku Free
```

### 4.4. Deploy frontend
```bash
# Cài Azure Static Web Apps CLI
npm install -g @azure/static-web-apps-cli

# Deploy
cd frontend
swa deploy ./dist \
  --app-name itss-ecommerce-web \
  --resource-group rg-itss-ecommerce
```

Hoặc dùng Azure Portal:
1. Vào Azure Portal → Static Web Apps
2. Chọn app `itss-ecommerce-web`
3. Upload folder `frontend/dist`

### 4.5. Configure CORS trên Backend
```bash
# Lấy URL của Static Web App
az staticwebapp show \
  --name itss-ecommerce-web \
  --resource-group rg-itss-ecommerce \
  --query "defaultHostname"

# Thêm CORS
az webapp cors add \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api \
  --allowed-origins https://itss-ecommerce-web.azurestaticapps.net
```

---

## ✅ BƯỚC 5: Kiểm tra & Test

### 5.1. URLs của bạn:
- **Frontend:** `https://itss-ecommerce-web.azurestaticapps.net`
- **Backend API:** `https://itss-ecommerce-api.azurewebsites.net/api`
- **Database:** `mysql-itss-ecommerce.mysql.database.azure.com`

### 5.2. Test các endpoints:
```bash
# Health check
curl https://itss-ecommerce-api.azurewebsites.net/api/health

# Products
curl https://itss-ecommerce-api.azurewebsites.net/api/products

# Login
curl -X POST https://itss-ecommerce-api.azurewebsites.net/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{"username":"admin","password":"your_password"}'
```

---

## 🔧 BƯỚC 6: CI/CD với GitHub Actions (Optional)

### 6.1. Tạo GitHub Repository
```bash
cd /Users/duc/Desktop/E-Commerce_ITSS
git init
git add .
git commit -m "Initial commit"
git remote add origin https://github.com/your-username/itss-ecommerce.git
git push -u origin main
```

### 6.2. Tạo file `.github/workflows/azure-deploy.yml`
```yaml
name: Deploy to Azure

on:
  push:
    branches: [ main ]

jobs:
  build-and-deploy:
    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@v3
    
    # Backend
    - name: Set up JDK 21
      uses: actions/setup-java@v3
      with:
        java-version: '21'
        distribution: 'temurin'
    
    - name: Build Backend
      run: |
        cd backend
        ./mvnw clean package -DskipTests
    
    - name: Deploy Backend
      uses: azure/webapps-deploy@v2
      with:
        app-name: itss-ecommerce-api
        publish-profile: ${{ secrets.AZURE_WEBAPP_PUBLISH_PROFILE }}
        package: backend/target/*.jar
    
    # Frontend
    - name: Set up Node.js
      uses: actions/setup-node@v3
      with:
        node-version: '18'
    
    - name: Build Frontend
      run: |
        cd frontend
        npm ci
        npm run build
    
    - name: Deploy Frontend
      uses: Azure/static-web-apps-deploy@v1
      with:
        azure_static_web_apps_api_token: ${{ secrets.AZURE_STATIC_WEB_APPS_API_TOKEN }}
        repo_token: ${{ secrets.GITHUB_TOKEN }}
        action: "upload"
        app_location: "/frontend"
        output_location: "dist"
```

### 6.3. Lấy secrets từ Azure
```bash
# Backend publish profile
az webapp deployment list-publishing-profiles \
  --name itss-ecommerce-api \
  --resource-group rg-itss-ecommerce \
  --xml

# Static Web Apps token
az staticwebapp secrets list \
  --name itss-ecommerce-web \
  --resource-group rg-itss-ecommerce
```

Thêm vào GitHub Secrets:
- `AZURE_WEBAPP_PUBLISH_PROFILE`
- `AZURE_STATIC_WEB_APPS_API_TOKEN`

---

## 💰 Chi phí (với Azure Student)

### FREE Services (không tốn credit):
- ✅ App Service F1 (Backend)
- ✅ Static Web Apps (Frontend)
- ✅ MySQL B1ms - 750h/tháng (~cả tháng)
- ✅ Bandwidth - 15GB/tháng

### Tổng: **$0/tháng** nếu dùng đúng free tier!

---

## 🔍 Troubleshooting

### Lỗi kết nối database:
```bash
# Kiểm tra firewall rules
az mysql flexible-server firewall-rule list \
  --resource-group rg-itss-ecommerce \
  --name mysql-itss-ecommerce

# Thêm IP của App Service
az mysql flexible-server firewall-rule create \
  --resource-group rg-itss-ecommerce \
  --name mysql-itss-ecommerce \
  --rule-name AllowAppService \
  --start-ip-address 0.0.0.0 \
  --end-ip-address 0.0.0.0
```

### Xem logs:
```bash
# Backend logs
az webapp log tail \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api

# Download logs
az webapp log download \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api
```

### Restart services:
```bash
# Restart backend
az webapp restart \
  --resource-group rg-itss-ecommerce \
  --name itss-ecommerce-api
```

---

## 📚 Tài liệu tham khảo

- Azure App Service: https://docs.microsoft.com/azure/app-service/
- Azure Static Web Apps: https://docs.microsoft.com/azure/static-web-apps/
- Azure MySQL: https://docs.microsoft.com/azure/mysql/
- Azure CLI: https://docs.microsoft.com/cli/azure/

---

## 🎯 Checklist Deploy

- [ ] Tạo Azure account
- [ ] Cài Azure CLI
- [ ] Tạo MySQL database
- [ ] Import dữ liệu
- [ ] Build backend JAR
- [ ] Deploy backend
- [ ] Cấu hình environment variables
- [ ] Build frontend
- [ ] Deploy frontend
- [ ] Cấu hình CORS
- [ ] Test toàn bộ hệ thống
- [ ] Setup CI/CD (optional)

---

**Lưu ý:** Thay các giá trị như passwords, JWT secret bằng giá trị thật của bạn!
