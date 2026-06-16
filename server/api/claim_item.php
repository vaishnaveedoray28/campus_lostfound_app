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

$item_id          = isset($data['item_id']) ? intval($data['item_id']) : 0;
$finder_phone_num = isset($data['finder_phone']) ? trim($data['finder_phone']) : '';

if ($item_id === 0 || empty($finder_phone_num)) {
    echo json_encode(["status" => "error", "message" => "Item ID and finder contact details are required."]);
    exit();
}

try {
    $query = "UPDATE items 
              SET status = 'Found', 
                  color = 'Finder Phone: ' || ?
              WHERE id = ?";
    
    $stmt = $db->prepare($query);
    $stmt->execute([$finder_phone_num, $item_id]);

    echo json_encode(["status" => "success", "message" => "Claim successfully recorded!"]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>