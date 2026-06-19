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

$item_id     = $data['item_id'] ?? 0;
$reporter_id = $data['reporter_id'] ?? 0;

if (empty($item_id) || empty($reporter_id)) {
    echo json_encode(["status" => "error", "message" => "Missing deletion parameters."]);
    exit();
}

try {
    // Crucial: Extra check ensures users can only delete their own reports
    $query = "DELETE FROM items WHERE id = ? AND reporter_id = ?";
    $stmt = $db->prepare($query);
    $stmt->execute([$item_id, $reporter_id]);

    echo json_encode([
        "status" => "success",
        "message" => "Report permanently removed from the system."
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Deletion rejected: " . $e->getMessage()]);
}
?>