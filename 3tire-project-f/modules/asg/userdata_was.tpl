#!/bin/bash
exec > >(tee /var/log/user-data.log|logger -t user-data -s 2>/dev/console) 2>&1
echo "Starting user data script"

# root 권한으로 실행
if [ "$(id -u)" -ne 0 ]; then
  exec sudo "$0" "$@"
fi

# 패키지 설치
dnf install -y httpd wget php-fpm php-mysqli php-json php php-devel

# Apache 설정 디렉토리 생성 및 권한 설정
mkdir -p /var/www/html
chown -R ec2-user:apache /var/www/html
chmod 2775 /var/www/html

# Apache 및 PHP 설정
echo "date.timezone = Asia/Seoul" > /etc/php.d/timezone.ini
echo "display_errors = On" > /etc/php.d/error_display.ini
echo "error_reporting = E_ALL" >> /etc/php.d/error_display.ini
echo "error_log = /var/log/php_errors.log" >> /etc/php.d/error_display.ini

# SELinux 설정
setsebool -P httpd_can_network_connect_db 1
setsebool -P httpd_can_network_connect 1

# DB 연결 정보 설정
cat > /var/www/html/db_config.php << EOF
<?php
\$host = '${db_endpoint}';
\$username = '${db_username}';
\$password = '${db_password}';
?>
EOF

# PHP 웹 애플리케이션 배포
cat > /var/www/html/index.php << 'INNEREOF'
<?php
// 데이터베이스 연결 설정
require_once('db_config.php');
$dbname = 'routine_db';

// mysqli를 사용한 데이터베이스 연결
$conn = new mysqli($host, $username, $password, $dbname);

if ($conn->connect_error) {
    error_log("DB 연결 실패 - Host: $host, User: $username, Error: " . $conn->connect_error);
    die("<pre>데이터베이스 연결 실패:\n" . 
        "Host: $host\n" .
        "Error: " . $conn->connect_error . "</pre>");
}

// UTF-8 설정
$conn->set_charset("utf8");

// 루틴 추가
if ($_SERVER['REQUEST_METHOD'] === 'POST' && isset($_POST['add'])) {
    $activity = $conn->real_escape_string($_POST['activity']);
    $category = $conn->real_escape_string($_POST['category']);
    
    $query = "INSERT INTO routines (activity, category) VALUES ('$activity', '$category')";
    $conn->query($query);
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// 루틴 삭제
if (isset($_GET['delete'])) {
    $id = $conn->real_escape_string($_GET['delete']);
    $query = "DELETE FROM routines WHERE id = '$id'";
    $conn->query($query);
    header("Location: " . $_SERVER['PHP_SELF']);
    exit;
}

// 전체 루틴 조회
$query = "SELECT * FROM routines ORDER BY created_at DESC";
$result = $conn->query($query);
$routines = $result->fetch_all(MYSQLI_ASSOC);

// 오늘의 루틴 (랜덤 3개)
$query = "SELECT * FROM routines ORDER BY RAND() LIMIT 3";
$result = $conn->query($query);
$daily_routines = $result->fetch_all(MYSQLI_ASSOC);

$conn->close();
?>

<!DOCTYPE html>
<html>
<head>
    <title>일일 루틴 관리</title>
    <meta charset="utf-8">
    <style>
        body { 
            font-family: Arial, sans-serif; 
            max-width: 800px; 
            margin: 0 auto; 
            padding: 20px;
            background-color: #f5f5f5;
        }
        .container { background: white; padding: 20px; border-radius: 8px; box-shadow: 0 2px 4px rgba(0,0,0,0.1); }
        h1 { color: #333; text-align: center; }
        .section { margin: 20px 0; padding: 20px; border: 1px solid #ddd; border-radius: 4px; }
        .routine-item { 
            background: #f9f9f9; 
            margin: 10px 0; 
            padding: 15px; 
            border-radius: 4px;
            display: flex;
            justify-content: space-between;
            align-items: center;
        }
        .delete-btn {
            color: white;
            background: #ff4444;
            padding: 5px 10px;
            border-radius: 3px;
            text-decoration: none;
        }
        form {
            display: flex;
            gap: 10px;
            margin-top: 20px;
        }
        input, select {
            padding: 8px;
            border: 1px solid #ddd;
            border-radius: 4px;
        }
        input[type="submit"] {
            background: #4CAF50;
            color: white;
            border: none;
            cursor: pointer;
            padding: 8px 16px;
        }
        .highlight { background-color: #e3f2fd; }
    </style>
</head>
<body>
    <div class="container">
        <h1>일일 루틴 관리</h1>
        
        <div class="section">
            <h2>오늘의 추천 루틴</h2>
            <?php foreach ($daily_routines as $routine): ?>
                <div class="routine-item highlight">
                    <div>
                        <strong><?php echo htmlspecialchars($routine['activity']); ?></strong>
                        <span>(<?php echo htmlspecialchars($routine['category']); ?>)</span>
                    </div>
                </div>
            <?php endforeach; ?>
        </div>

        <div class="section">
            <h2>새로운 루틴 추가</h2>
            <form method="POST">
                <input type="text" name="activity" placeholder="루틴 내용" required>
                <select name="category" required>
                    <option value="운동">운동</option>
                    <option value="학습">학습</option>
                    <option value="취미">취미</option>
                    <option value="건강">건강</option>
                    <option value="생활">생활</option>
                    <option value="자기계발">자기계발</option>
                </select>
                <input type="submit" name="add" value="추가">
            </form>
        </div>

        <div class="section">
            <h2>전체 루틴 목록</h2>
            <?php foreach ($routines as $routine): ?>
                <div class="routine-item">
                    <div>
                        <strong><?php echo htmlspecialchars($routine['activity']); ?></strong>
                        <span>(<?php echo htmlspecialchars($routine['category']); ?>)</span>
                    </div>
                    <a href="?delete=<?php echo $routine['id']; ?>" class="delete-btn" 
                       onclick="return confirm('정말 삭제하시겠습니까?')">삭제</a>
                </div>
            <?php endforeach; ?>
        </div>
    </div>
</body>
</html>
INNEREOF

# 최종 권한 설정
chown -R apache:apache /var/www/html/*
chmod -R 644 /var/www/html/*
chmod 755 /var/www/html

# 서비스 시작
systemctl enable --now php-fpm
systemctl enable --now httpd

# 설치된 패키지 확인
echo "[INFO] Checking installed packages"
rpm -qa | grep httpd
rpm -qa | grep php

echo "User data script completed at $(date)" 