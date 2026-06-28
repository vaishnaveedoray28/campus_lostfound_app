<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET, POST");

require_once "db.php";

$reporter_id = $_GET['reporter_id'] ?? 0;
$deduct_points = (int)($_GET['deduct_points'] ?? 0);

if (empty($reporter_id)) {

    $rawData = file_get_contents("php://input");
    $data = json_decode($rawData, true);
    $reporter_id = $data['reporter_id'] ?? 0;
    $deduct_points = (int)($data['deduct_points'] ?? 0);
}

if (empty($reporter_id)) {
    echo json_encode(["status" => "error", "message" => "Reporter identification required."]);
    exit();
}

try {
    if ($deduct_points > 0) {
        $updatePointsQuery = "UPDATE users SET points = MAX(0, points - ?) WHERE id = ?";
        $updatePointsStmt = $db->prepare($updatePointsQuery);
        $updatePointsStmt->execute([$deduct_points, $reporter_id]);
    }

    $query = "SELECT 
                i.id, 
                i.item_name, 
                i.status, 
                i.place,
                f.name AS finder_name,
                f.phone AS finder_phone
              FROM items i
              LEFT JOIN users f ON i.finder_id = f.id
              WHERE i.reporter_id = ?
              ORDER BY i.id DESC";
              
    $stmt = $db->prepare($query);
    $stmt->execute([$reporter_id]);
    $updates = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $pointsQuery = "SELECT points FROM users WHERE id = ? LIMIT 1";
    $pointsStmt = $db->prepare($pointsQuery);
    $pointsStmt->execute([$reporter_id]);
    $userRow = $pointsStmt->fetch(PDO::FETCH_ASSOC);
    $freshPoints = $userRow ? (int)$userRow['points'] : 0;

    echo json_encode([
        "status" => "success",
        "updates" => $updates,
        "current_points" => $freshPoints
    ]);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(["status" => "error", "message" => "Failed to fetch updates: " . $e->getMessage()]);
}
?>