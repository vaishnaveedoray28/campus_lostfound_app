<?php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type");
header("Content-Type: application/json");
date_default_timezone_set('Asia/Kuala_Lumpur');

require_once "db.php";

$data = json_decode(file_get_contents("php://input"), true);

if (
    empty($data["name"]) || empty($data["email"]) || empty($data["matric_no"]) ||
    empty($data["inasis"]) || empty($data["phone"]) || empty($data["password"]) || empty($data["role"])
) {
    echo json_encode(["status" => "error", "message" => "All fields are required"]);
    exit;
}

$name = trim($data["name"]);
$email = trim($data["email"]);
$matric_no = trim($data["matric_no"]);
$inasis = trim($data["inasis"]);
$phone = trim($data["phone"]);
$password = $data["password"];
$role = trim($data["role"]);

$hashedPassword = password_hash($password, PASSWORD_DEFAULT);
$createdAt = date('Y-m-d H:i:s');

try {
    $db->beginTransaction();

    $insert = $db->prepare("
        INSERT INTO users (name, email, matric_no, inasis, phone, password, role, created_at, is_verified, points)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, 1, 0)
    ");

    $insert->execute([$name, $email, $matric_no, $inasis, $phone, $hashedPassword, $role, $createdAt]);
    $db->commit();

    echo json_encode(["status" => "success", "message" => "Account created successfully!"]);
} catch (Throwable $e) {
    if ($db->inTransaction()) { $db->rollBack(); }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>