<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

if ($_SERVER['REQUEST_METHOD'] === 'OPTIONS') {
    http_response_code(200);
    exit();
}

require_once "db.php";

$rawData = file_get_contents("php://input");
$data = json_decode($rawData, true);

$name      = trim($data['name'] ?? '');
$email     = trim($data['email'] ?? '');
$matric_no = trim($data['matric_no'] ?? '');
$inasis    = trim($data['inasis'] ?? '');
$phone     = trim($data['phone'] ?? '');
$raw_password = trim($data['password'] ?? '');

if (empty($name) || empty($email) || empty($raw_password)) {
    echo json_encode(["status" => "error", "message" => "Required fields missing."]);
    exit();
}

$hashed_password = password_hash($raw_password, PASSWORD_BCRYPT);

try {
    $query = "INSERT INTO users (name, email, matric_no, inasis, phone, password, points) 
              VALUES (?, ?, ?, ?, ?, ?, 0)";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$name, $email, $matric_no, $inasis, $phone, $hashed_password]);

    echo json_encode([
        "status" => "success",
        "message" => "User registered successfully!"
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Registration failed: " . $e->getMessage()
    ]);
}
?>