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

$item_id      = isset($data['item_id']) ? intval($data['item_id']) : 0;
$finder_id    = isset($data['finder_id']) ? intval($data['finder_id']) : 0;
$finder_phone = isset($data['finder_phone']) ? trim($data['finder_phone']) : '';

if ($item_id === 0 || $finder_id === 0 || empty($finder_phone)) {
    echo json_encode(["status" => "error", "message" => "Item ID, Finder ID, and contact details are required."]);
    exit();
}

try {
    $db->beginTransaction();

    // 1. Update the item's state, tracking id, and clean phone number destination column
    $queryItem = "UPDATE items 
                  SET status = 'Found', 
                      finder_id = ?, 
                      finder_phone = ?
                  WHERE id = ?";
    $stmtItem = $db->prepare($queryItem);
    $stmtItem->execute([$finder_id, $finder_phone, $item_id]);

    // 2. Add 10 points permanently to the helper's account table row balance
    $queryPoints = "UPDATE users 
                    SET points = points + 10 
                    WHERE id = ?";
    $stmtPoints = $db->prepare($queryPoints);
    $stmtPoints->execute([$finder_id]);

    $db->commit();
    echo json_encode(["status" => "success", "message" => "Claim saved! 10 points added to database successfully."]);
} catch (PDOException $e) {
    if ($db->inTransaction()) { $db->rollBack(); }
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>