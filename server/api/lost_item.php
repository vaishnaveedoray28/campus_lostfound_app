<?php
// C:\xampp\htdocs\lost_found_api\lost_item.php
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

// Map the items exactly to what Flutter is sending
$reporter_id = isset($data['reporter_id']) ? intval($data['reporter_id']) : 1; // Default fallback to 1 if empty
$item_name   = isset($data['item_name']) ? trim($data['item_name']) : '';
$description = isset($data['description']) ? trim($data['description']) : '';
$color       = isset($data['color']) ? trim($data['color']) : '';
$date_lost   = isset($data['date_lost']) ? trim($data['date_lost']) : '';
$place       = isset($data['place']) ? trim($data['place']) : '';
$image_path  = isset($data['image_path']) ? trim($data['image_path']) : '';

try {
    $query = "INSERT INTO items (reporter_id, item_name, description, color, date_lost, place, image_path, status) 
              VALUES (?, ?, ?, ?, ?, ?, ?, 'Lost')";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$reporter_id, $item_name, $description, $color, $date_lost, $place, $image_path]);

    echo json_encode(["status" => "success", "message" => "Saved successfully!"]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>