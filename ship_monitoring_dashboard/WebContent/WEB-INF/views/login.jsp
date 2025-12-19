<%@ page contentType="text/html; charset=UTF-8" %>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>VMS Login</title>
    <link href="https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap" rel="stylesheet">
    <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.4.0/css/all.min.css">
    
    <style>
        /* 초기화 */
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Inter', sans-serif; }

        /* 배경 설정 */
        body {
            display: flex;
            justify-content: center;
            align-items: center;
            height: 100vh;
            background: linear-gradient(135deg, #2c3e50 0%, #1a252f 100%);
            background-size: 200% 200%;
            animation: subtleGradient 10s ease infinite;
            color: #333;
        }

        @keyframes subtleGradient {
            0% { background-position: 0% 50%; }
            50% { background-position: 100% 50%; }
            100% { background-position: 0% 50%; }
        }

        /* 로그인 카드 */
        .login-card {
            background: #ffffff;
            padding: 3.5rem 2.5rem;
            border-radius: 12px; 
            box-shadow: 0 20px 50px rgba(0, 0, 0, 0.3); /* 그림자를 진하게 */
            width: 100%;
            max-width: 400px;
            text-align: center;
            
            /* 등장 애니메이션 */
            opacity: 0;
            transform: translateY(20px);
            animation: fadeInUp 0.8s cubic-bezier(0.2, 0.8, 0.2, 1) forwards;
        }

        @keyframes fadeInUp {
            to { opacity: 1; transform: translateY(0); }
        }

        /* 헤더 디자인 */
        .login-header { margin-bottom: 2.5rem; }
        .login-header i {
            font-size: 3.5rem;
            color: #2c3e50; 
            margin-bottom: 15px;
            animation: float 4s ease-in-out infinite;
        }
        .login-header h2 {
            font-size: 1.8rem;
            color: #1a252f; 
            font-weight: 700;
            margin-bottom: 5px;
        }
        .login-header p {
            color: #7f8c8d; 
            font-size: 0.95rem;
            font-weight: 500;
        }

        @keyframes float {
            0%, 100% { transform: translateY(0); }
            50% { transform: translateY(-8px); }
        }

        /* 입력창 스타일링 */
        .input-group {
            position: relative;
            margin-bottom: 1.2rem;
            text-align: left;
        }
        .input-group i {
            position: absolute;
            left: 15px;
            top: 50%;
            transform: translateY(-50%);
            color: #95a5a6;
            font-size: 1.1rem;
            transition: color 0.3s ease;
        }
        .input-group input {
            width: 100%;
            padding: 14px 14px 14px 45px;
            border: 2px solid #ecf0f1;
            border-radius: 8px; 
            font-size: 1rem;
            color: #2c3e50;
            outline: none;
            transition: all 0.3s ease;
            background: #fdfdfd;
        }
        
        /* 포커스 효과 */
        .input-group input:focus {
            border-color: #2c3e50; 
            background: #fff;
        }
        .input-group input:focus + i {
            color: #2c3e50;
        }
        .input-group input::placeholder {
            color: #bdc3c7;
        }

        /* 버튼 디자인 */
        .btn-login {
            width: 100%;
            padding: 16px;
            background: #2c3e50; 
            color: white;
            border: none;
            border-radius: 8px;
            font-size: 1rem;
            font-weight: 600;
            cursor: pointer;
            transition: all 0.3s ease;
            margin-top: 10px;
        }

        .btn-login:hover {
            background: #1a252f;
            transform: translateY(-2px);
            box-shadow: 0 5px 15px rgba(44, 62, 80, 0.4);
        }
        .btn-login:active {
            transform: translateY(0);
        }

        /* 푸터 */
        .login-footer {
            margin-top: 2.5rem;
            font-size: 0.85rem;
            color: #95a5a6;
        }
    </style>
</head>
<body>

    <div class="login-card">
        <div class="login-header">
            <i class="fas fa-ship"></i>
            <h2>VMS Login</h2>
            <p>Monitor Your Fleet Securely</p>
        </div>

        <form action="/loginProcess" method="post">
            <div class="input-group">
                <input type="text" name="id" placeholder="ID" required autocomplete="off">
                <i class="fas fa-user"></i>
            </div>
            
            <div class="input-group">
                <input type="password" name="pw" placeholder="Password" required>
                <i class="fas fa-lock"></i>
            </div>

            <button type="submit" class="btn-login">
                Login
            </button>
        </form>

        <div class="login-footer">
            &copy; 2025 made by Newl. All rights reserved.
        </div>
    </div>

</body>
</html>