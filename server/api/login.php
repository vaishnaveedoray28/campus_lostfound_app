<?php
// login.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);

$email = trim($data["email"] ?? '');
$password = $data["password"] ?? '';

try {
    $stmt = $db->prepare("SELECT id, name, email, matric_no, inasis, phone, password, role, points FROM users WHERE email = ? LIMIT 1");
    $stmt->execute([$email]);
    $user = $stmt->fetch(PDO::FETCH_ASSOC);

    if (!$user || !password_verify($password, $user["password"])) {
        echo json_encode(["status" => "error", "message" => "Invalid email or password"]);
        exit;
    }

    unset($user["password"]);
    echo json_encode(["status" => "success", "message" => "Login successful", "user" => $user]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>