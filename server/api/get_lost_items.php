<?php
header("Access-Control-Allow-Origin: *");
header("Content-Type: application/json; charset=UTF-8");
header("Access-Control-Allow-Methods: GET");

require_once "db.php";

try {
    $query = "SELECT 
                i.id, 
                i.item_name, 
                i.description, 
                i.color, 
                i.date_lost, 
                i.place, 
                i.status,
                u.name AS reporter_name,
                u.matric_no AS reporter_matric
              FROM items i
              LEFT JOIN users u ON i.reporter_id = u.id
              WHERE i.status = 'Missing'
              ORDER BY i.id DESC";
              
    $stmt = $db->prepare($query);
    $stmt->execute();
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "items" => $items
    ]);

} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode([
        "status" => "error",
        "message" => "Failed to fetch items: " . $e->getMessage()
    ]);
}
?>