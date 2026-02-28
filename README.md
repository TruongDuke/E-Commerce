# 🛒 ITSS E-Commerce Platform

Hệ thống thương mại điện tử bán sách, CD/LP, DVD với tính năng giỏ hàng, thanh toán trực tuyến và quản trị viên.

## 🌐 Live Demo

- **🎨 Frontend:** [https://e-commerce-sigma-green.vercel.app](https://e-commerce-sigma-green.vercel.app)
- **⚙️ Backend API:** [https://e-commerce-production-7be5.up.railway.app](https://e-commerce-production-7be5.up.railway.app)
- **🏥 Health Check:** [https://e-commerce-production-7be5.up.railway.app/api/health](https://e-commerce-production-7be5.up.railway.app/api/health)

## ✨ Tính năng chính

- 🔐 Đăng ký/Đăng nhập với JWT authentication
- 📚 Xem và tìm kiếm sản phẩm (Sách, CD/LP, DVD)
- 🛒 Giỏ hàng và quản lý đơn hàng
- 💳 Thanh toán qua VNPay (sandbox)
- 📦 Quản lý thông tin giao hàng
- 👨‍💼 Admin dashboard (quản lý sản phẩm, đơn hàng)

## 🛠️ Tech Stack

**Frontend:** React + TypeScript + Vite + TailwindCSS  
**Backend:** Spring Boot 3.4.4 + Java 21 + Spring Security + JWT  
**Database:** MySQL 9.4  
**Deployment:** Vercel (Frontend) + Railway (Backend + Database)

## 📁 Cấu trúc dự án

```
E-Commerce/
├── backend/                 # Spring Boot backend
│   ├── src/
│   │   ├── main/
│   │   │   ├── java/
│   │   │   │   ├── code/           # Main application
│   │   │   │   ├── config/         # CORS, Security config
│   │   │   │   ├── controllers/    # REST controllers
│   │   │   │   ├── models/         # JPA entities
│   │   │   │   ├── repositories/   # Data access
│   │   │   │   ├── services/       # Business logic
│   │   │   │   └── security/       # JWT, Authentication
│   │   │   └── resources/
│   │   │       ├── application.YML
│   │   │       └── application-prod.yml
│   │   └── test/
│   ├── pom.xml
│   ├── Dockerfile
│   └── railway.json
│
└── frontend/               # React frontend
    ├── src/
    │   ├── components/    # UI components
    │   ├── views/         # Pages
    │   ├── services/      # API services
    │   ├── contexts/      # React contexts
    │   ├── config/        # API config
    │   └── utils/         # Helper functions
    ├── package.json
    ├── vite.config.ts
    ├── vercel.json
    └── .env.production
```

## 🚀 Installation & Setup

### Prerequisites
- Node.js 18+ và npm
- Java 21
- Maven 3.9+
- MySQL 9.4+

### Backend Setup

1. **Clone repository:**
```bash
git clone https://github.com/TruongDuke/E-Commerce.git
cd E-Commerce/backend
```

2. **Cấu hình database (application.YML):**
```yaml
spring:
  datasource:
    url: jdbc:mysql://localhost:3306/aims_database
    username: root
    password: your_password
```

3. **Import database:**
```bash
mysql -u root -p aims_database < AIMS_database.sql
```

4. **Chạy backend:**
```bash
./mvnw spring-boot:run
```

Backend chạy tại: `http://localhost:8080`

### Frontend Setup

1. **Di chuyển vào thư mục frontend:**
```bash
cd frontend
```

2. **Install dependencies:**
```bash
npm install
```

3. **Tạo file `.env.local`:**
```env
VITE_API_URL=http://localhost:8080
```

4. **Chạy development server:**
```bash
npm run dev
```

Frontend chạy tại: `http://localhost:5173`

## 🌐 Deployment

### Frontend (Vercel)

1. Push code lên GitHub
2. Import project vào Vercel
3. Chọn Root Directory: `frontend`
4. Thêm Environment Variable:
   ```
   VITE_API_URL=https://e-commerce-production-7be5.up.railway.app
   ```
5. Deploy!

### Backend (Railway)

1. Push code lên GitHub
2. Tạo MySQL database trên Railway
3. Import project từ GitHub
4. Thêm Environment Variables:
   ```
   SPRING_DATASOURCE_URL=jdbc:mysql://...
   SPRING_DATASOURCE_USERNAME=root
   SPRING_DATASOURCE_PASSWORD=...
   JWT_SECRET=your-jwt-secret-key
   SPRING_PROFILES_ACTIVE=prod
   VNPAY_TMNCODE=...
   VNPAY_HASHSECRET=...
   VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
   VNPAY_RETURNURL=https://your-domain.vercel.app/payment/vnpay-return
   ```
5. Deploy!

## 📡 API Endpoints

### Authentication
```
POST /api/users/login           # Đăng nhập
POST /api/users/signup          # Đăng ký
POST /api/auth/change-password  # Đổi mật khẩu
```

### Products
```
GET  /api/products              # Danh sách sản phẩm
GET  /api/products/{id}         # Chi tiết sản phẩm
GET  /api/products/search/{title}  # Tìm kiếm
GET  /api/products/category/{category}  # Lọc theo danh mục
```

### Cart
```
GET  /api/cart                  # Xem giỏ hàng
POST /api/cart                  # Thêm vào giỏ
PUT  /api/cart/{id}             # Cập nhật số lượng
DELETE /api/cart/{id}           # Xóa khỏi giỏ
```

### Orders
```
POST /api/orders                # Tạo đơn hàng
GET  /api/orders                # Lịch sử đơn hàng
GET  /api/orders/{id}           # Chi tiết đơn hàng
```

### Payment
```
POST /api/payment/vnpay         # Tạo URL thanh toán VNPay
GET  /api/payment/vnpay-return  # Xử lý kết quả thanh toán
```

### Admin
```
POST   /api/products/add-product  # Thêm sản phẩm
PUT    /api/products/{id}         # Sửa sản phẩm
DELETE /api/products/{id}         # Xóa sản phẩm
GET    /api/admin/orders          # Quản lý đơn hàng
```

## 🔐 Environment Variables

### Backend (.env hoặc Railway Config)
```env
SPRING_DATASOURCE_URL=jdbc:mysql://host:port/database
SPRING_DATASOURCE_USERNAME=root
SPRING_DATASOURCE_PASSWORD=password
JWT_SECRET=your-jwt-secret-minimum-32-characters
SPRING_PROFILES_ACTIVE=prod
VNPAY_TMNCODE=your-vnpay-tmn-code
VNPAY_HASHSECRET=your-vnpay-hash-secret
VNPAY_URL=https://sandbox.vnpayment.vn/paymentv2/vpcpay.html
VNPAY_RETURNURL=https://your-frontend-url/payment/vnpay-return
```

### Frontend (.env.production)
```env
VITE_API_URL=https://your-backend-url
```

## 👥 Team Members

- **Trương Đức** - Full Stack Developer

## 📄 License

This project is licensed under the MIT License.

## 🙏 Acknowledgments

- Spring Boot Documentation
- React Documentation
- VNPay API Integration
- Railway & Vercel Platform

---

**⭐ Nếu thấy project hữu ích, hãy cho một star!**
