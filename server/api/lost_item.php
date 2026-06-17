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

$reporter_id = $data['reporter_id'] ?? $data['reporterId'] ?? 0;
$item_name   = trim($data['item_name'] ?? $data['itemName'] ?? '');
$description = trim($data['description'] ?? '');
$color       = trim($data['color'] ?? '');
$date_lost   = trim($data['date_lost'] ?? $data['dateLost'] ?? '');
$place       = trim($data['place'] ?? '');
$image_path  = trim($data['image_path'] ?? $data['imagePath'] ?? '');

if (empty($reporter_id) || $reporter_id == 0) {
    $reporter_id = 3; 
}

try {
    // We set status to 'Missing' so it perfectly matches your frontend feed expectations
    $query = "INSERT INTO items (reporter_id, item_name, description, color, date_lost, place, image_path, status) 
              VALUES (?, ?, ?, ?, ?, ?, ?, 'Missing')";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$reporter_id, $item_name, $description, $color, $date_lost, $place, $image_path]);

    echo json_encode([
        "status" => "success", 
        "message" => "Item completely written to database!"
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error", 
        "message" => "Database injection rejected: " . $e->getMessage()
    ]);
}
?>