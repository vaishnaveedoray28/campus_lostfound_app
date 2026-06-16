<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");

require_once "db.php";

$userId = isset($_GET['user_id']) ? intval($_GET['user_id']) : 0;

try {
    $query = "SELECT * FROM items WHERE reporter_id = ? ORDER BY id DESC";
    $stmt = $db->prepare($query);
    $stmt->execute([$userId]);
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    $pointsQuery = "SELECT points FROM users WHERE id = ? LIMIT 1";
    $pointsStmt = $db->prepare($pointsQuery);
    $pointsStmt->execute([$userId]);
    $userRow = $pointsStmt->fetch(PDO::FETCH_ASSOC);
    $points = $userRow ? intval($userRow['points']) : 0;

    echo json_encode([
        "status" => "success", 
        "items" => $items,
        "user_points" => $points
    ]);
} catch (PDOException $e) {
    echo json_encode(["status" => "error", "message" => $e->getMessage()]);
}
?>