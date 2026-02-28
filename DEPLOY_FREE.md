# 🆓 Deploy HOÀN TOÀN FREE - Không cần thẻ tín dụng

## 🎯 Option tốt nhất cho project này

---

## ✨ OPTION 1: Railway + Vercel (Recommended)

### 💾 Database: Railway (MySQL)
**Free tier:** 500h/tháng, 1GB RAM, 1GB storage

### 1. Deploy Database trên Railway

1. **Đăng ký:** https://railway.app (dùng GitHub login)

2. **Tạo MySQL Database:**
```bash
# Qua Railway Dashboard
- New Project → Deploy MySQL
- Copy connection string
```

3. **Import dữ liệu:**
```bash
# Lấy connection string từ Railway
# Format: mysql://user:password@host:port/database

mysql -h containers-us-west-xxx.railway.app \
  -P 1234 \
  -u root \
  -p \
  railway < backend/AIMS_database.sql
```

### 2. Deploy Backend trên Railway

1. **Tạo service mới:**
```bash
# Railway Dashboard
- New → GitHub Repo
- Chọn repo của bạn
- Root directory: /backend
```

2. **Cấu hình:**
```bash
# Railway Settings → Variables
SPRING_PROFILES_ACTIVE=prod
MYSQL_HOST=containers-us-west-xxx.railway.app
MYSQL_PORT=1234
MYSQL_DATABASE=railway
MYSQL_USER=root
MYSQL_PASSWORD=xxx
JWT_SECRET=your-secret-key-minimum-32-characters
```

3. **Tạo file railway.json:**
```json
{
  "build": {
    "builder": "NIXPACKS",
    "buildCommand": "./mvnw clean package -DskipTests"
  },
  "deploy": {
    "startCommand": "java -jar target/Project_ITSS-0.0.1-SNAPSHOT.jar",
    "healthcheckPath": "/api/health"
  }
}
```

### 3. Deploy Frontend trên Vercel

1. **Đăng ký:** https://vercel.com (dùng GitHub)

2. **Import project:**
```bash
- New Project → Import Git Repository
- Select: frontend folder
- Framework Preset: Vite
- Root Directory: frontend
```

3. **Environment Variables:**
```bash
VITE_API_URL=https://your-backend.up.railway.app/api
```

4. **Deploy:** Vercel tự động build và deploy!

**URLs:**
- Backend: `https://your-project.up.railway.app`
- Frontend: `https://your-project.vercel.app`

---

## 🚀 OPTION 2: Render (All-in-one)

**Free tier:** Backend sleep sau 15 phút không dùng, 750h/tháng

### 1. Deploy Database

1. **Đăng ký:** https://render.com
2. **New → PostgreSQL** (hoặc dùng external MySQL)
3. Copy connection string

### 2. Deploy Backend

1. **New → Web Service**
```yaml
Name: itss-backend
Environment: Docker
Build Command: cd backend && ./mvnw clean package -DskipTests
Start Command: java -jar backend/target/Project_ITSS-0.0.1-SNAPSHOT.jar
```

2. **Environment Variables:**
```bash
SPRING_PROFILES_ACTIVE=prod
SPRING_DATASOURCE_URL=your_db_url
SPRING_DATASOURCE_USERNAME=xxx
SPRING_DATASOURCE_PASSWORD=xxx
JWT_SECRET=xxx
```

### 3. Deploy Frontend

1. **New → Static Site**
```yaml
Build Command: cd frontend && npm install && npm run build
Publish Directory: frontend/dist
```

2. **Environment Variables:**
```bash
VITE_API_URL=https://itss-backend.onrender.com/api
```

---

## 🐳 OPTION 3: Fly.io (Recommended for production-like)

**Free tier:** 3 VMs shared-cpu-1x, 3GB persistent storage

### 1. Cài Fly CLI
```bash
brew install flyctl
flyctl auth signup
```

### 2. Deploy Backend

```bash
cd backend

# Tạo Dockerfile
cat > Dockerfile << 'EOF'
FROM maven:3.9-eclipse-temurin-21 AS build
WORKDIR /app
COPY pom.xml .
COPY src ./src
RUN mvn clean package -DskipTests

FROM eclipse-temurin:21-jre
WORKDIR /app
COPY --from=build /app/target/*.jar app.jar
EXPOSE 8080
CMD ["java", "-jar", "app.jar"]
EOF

# Deploy
flyctl launch --name itss-backend
flyctl secrets set \
  SPRING_PROFILES_ACTIVE=prod \
  JWT_SECRET=xxx

# Scale to free tier
flyctl scale count 1
flyctl scale vm shared-cpu-1x
```

### 3. Deploy MySQL trên Fly

```bash
flyctl postgres create --name itss-db
flyctl postgres attach itss-db --app itss-backend
```

### 4. Deploy Frontend trên Vercel
(Same as Option 1)

---

## 📊 SO SÁNH CÁC PLATFORM FREE

| Platform | Backend | Database | Frontend | Sleep? | Bandwidth |
|----------|---------|----------|----------|--------|-----------|
| **Railway** | ✅ 500h/tháng | ✅ MySQL | ❌ | ✅ Có | 100GB |
| **Vercel** | ⚠️ Serverless only | ❌ | ✅ Unlimited | ❌ | 100GB |
| **Render** | ✅ 750h/tháng | ✅ PostgreSQL | ✅ | ✅ Có (15min) | 100GB |
| **Fly.io** | ✅ 3 VMs | ✅ PostgreSQL | ❌ | ❌ | 160GB |
| **Netlify** | ⚠️ Functions only | ❌ | ✅ Unlimited | ❌ | 100GB |

---

## 🎖️ KHUYẾN NGHỊ

### 🥇 **Best Choice: Railway + Vercel**
**Lý do:**
- ✅ Setup đơn giản nhất
- ✅ MySQL native (không cần chuyển PostgreSQL)
- ✅ Không sleep (nếu < 500h/tháng)
- ✅ GitHub integration tốt
- ✅ Free SSL
- ❌ Limited to 500h/tháng

### 🥈 **Alternative: Render**
**Lý do:**
- ✅ All-in-one (backend + frontend + DB)
- ✅ 750h/tháng
- ✅ Easy setup
- ❌ Sleep sau 15 phút không dùng
- ❌ Phải chuyển sang PostgreSQL

### 🥉 **Advanced: Fly.io**
**Lý do:**
- ✅ Không sleep
- ✅ Production-grade
- ✅ 3 VMs
- ❌ Setup phức tạp hơn
- ❌ Cần Docker

---

## 🔥 HƯỚNG DẪN NHANH - Railway + Vercel (5 phút)

### Bước 1: Push code lên GitHub
```bash
cd /Users/duc/Desktop/E-Commerce_ITSS
git init
git add .
git commit -m "Initial commit"
gh repo create itss-ecommerce --public --source=. --push
```

### Bước 2: Deploy Database (Railway)
1. Vào https://railway.app
2. New Project → Deploy MySQL
3. Copy connection URL
4. Connect bằng MySQL Workbench và import `AIMS_database.sql`

### Bước 3: Deploy Backend (Railway)
1. New → GitHub Repo → chọn repo
2. Settings → Root Directory: `/backend`
3. Variables → Add:
```
SPRING_DATASOURCE_URL=jdbc:mysql://[railway-host]:3306/railway
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=[password]
JWT_SECRET=[your-secret]
```

### Bước 4: Deploy Frontend (Vercel)
1. Vào https://vercel.com
2. New Project → Import từ GitHub
3. Root Directory: `frontend`
4. Environment Variable:
```
VITE_API_URL=https://[backend-url].up.railway.app/api
```
5. Deploy!

### ✅ XONG! URLs:
- Frontend: `https://itss-ecommerce.vercel.app`
- Backend: `https://itss-ecommerce.up.railway.app`

---

## 💡 TIPS

### Keep Railway awake (tránh sleep):
```bash
# Tạo cron job ping mỗi 10 phút
# Dùng cron-job.org hoặc UptimeRobot
```

### Monitor usage:
```bash
# Railway: Dashboard → Metrics
# Vercel: Dashboard → Analytics
```

### Custom domain (FREE):
```bash
# Vercel: Settings → Domains → Add
# Railway: Settings → Domains → Add
```

---

## 🆘 Troubleshooting

### Railway build failed:
```bash
# Thêm file railway.toml
[build]
builder = "NIXPACKS"

[deploy]
startCommand = "java -jar target/Project_ITSS-0.0.1-SNAPSHOT.jar"
```

### Vercel build failed:
```bash
# Đảm bảo package.json có:
"scripts": {
  "build": "vite build",
  "preview": "vite preview"
}
```

### CORS errors:
```java
// Thêm vào SecurityConfig.java
@Bean
public CorsFilter corsFilter() {
    CorsConfiguration config = new CorsConfiguration();
    config.addAllowedOrigin("https://your-frontend.vercel.app");
    config.addAllowedMethod("*");
    config.addAllowedHeader("*");
    // ...
}
```

---

## 📈 Nâng cấp sau này

### Khi project lớn:
1. **Railway Pro:** $5/tháng → unlimited hours
2. **Vercel Pro:** $20/tháng → better performance
3. **Fly.io Scale:** Pay as you go

### Hoặc chuyển sang Azure Student ($100 credit)

---

## ✅ Checklist Deploy FREE

- [ ] Push code lên GitHub
- [ ] Đăng ký Railway (GitHub login)
- [ ] Deploy MySQL trên Railway
- [ ] Import database
- [ ] Deploy Backend trên Railway
- [ ] Cấu hình environment variables
- [ ] Đăng ký Vercel (GitHub login)
- [ ] Deploy Frontend trên Vercel
- [ ] Test toàn bộ
- [ ] Setup monitoring (optional)

**Tổng thời gian:** ~10-15 phút!
