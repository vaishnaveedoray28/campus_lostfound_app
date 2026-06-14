<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
date_default_timezone_set('Asia/Kuala_Lumpur');

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);

if (empty($data["email"]) || empty($data["password"])) {
    echo json_encode([
        "status" => "error",
        "message" => "Email and password are required"
    ]);
    exit;
}

$email = trim($data["email"]);
$password = $data["password"];

if (!filter_var($email, FILTER_VALIDATE_EMAIL)) {
    echo json_encode([
        "status" => "error",
        "message" => "Invalid email format"
    ]);
    exit;
}

try {
    $stmt = $db->prepare("
        SELECT
            id, name, email, phone, password, role, profile_image, created_at,
            is_verified, points
        FROM users
        WHERE email = ?
        LIMIT 1
    ");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($password, $user["password"])) {
        echo json_encode([
            "status" => "error",
            "message" => "Invalid email or password"
        ]);
        exit;
    }

    if ((int) ($user["is_verified"] ?? 0) !== 1) {
        echo json_encode([
            "status" => "error",
            "message" => "Please verify your email account first."
        ]);
        exit;
    }

    unset($user["password"]);

    echo json_encode([
        "status" => "success",
        "message" => "Login successful",
        "user" => [
            "id" => (int)$user['id'],
            "name" => $user['name'],
            "email" => $user['email'],
            "phone" => $user['phone'],
            "role" => $user['role'],
            "points" => (int)($user['points'] ?? 0)
        ]
    ]);
} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => $e->getMessage()
    ]);
}
?>