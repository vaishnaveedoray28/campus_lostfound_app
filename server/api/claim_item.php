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

$item_id      = $data['item_id'] ?? 0;
$finder_id    = $data['finder_id'] ?? 0;
$finder_phone = trim($data['finder_phone'] ?? '');

if (empty($item_id) || empty($finder_id) || empty($finder_phone)) {
    echo json_encode(["status" => "error", "message" => "Missing claim transaction parameters."]);
    exit();
}

try {
    $db->beginTransaction();

    $queryItem = "UPDATE items SET finder_id = ?, finder_phone = ?, status = 'Found' WHERE id = ?";
    $stmtItem = $db->prepare($queryItem);
    $stmtItem->execute([$finder_id, $finder_phone, $item_id]);

    $queryPoints = "UPDATE users SET points = points + 10 WHERE id = ?";
    $stmtPoints = $db->prepare($queryPoints);
    $stmtPoints->execute([$finder_id]);

    $db->commit();
    echo json_encode([
        "status" => "success",
        "message" => "Claim logged successfully! Reward tokens added."
    ]);
} catch (PDOException $e) {
    if ($db->inTransaction()) {
        $db->rollBack();
    }
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Transaction rejected: " . $e->getMessage()]);
}
?>