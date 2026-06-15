<?php
// C:\xampp\htdocs\lost_found_api\get_lost_items.php
header("Access-Control-Allow-Origin: *");
header("Access-Control-Allow-Headers: Content-Type, Access-Control-Allow-Headers, Authorization, X-Requested-With");
header("Access-Control-Allow-Methods: GET, POST, OPTIONS");
header("Content-Type: application/json; charset=UTF-8");

require_once "db.php";

try {
    // Left Join guarantees the item displays even if reporter account metadata links are loose
    $query = "SELECT items.*, 
                     IFNULL(users.name, 'Campus User') as reporter_name, 
                     IFNULL(users.phone, 'No Phone') as reporter_phone, 
                     IFNULL(users.matric_no, 'N/A') as reporter_matric, 
                     IFNULL(users.inasis, 'Varsity') as reporter_inasis
              FROM items 
              LEFT JOIN users ON items.reporter_id = users.id 
              WHERE items.status = 'Lost'
              ORDER BY items.id DESC";

    $stmt = $db->prepare($query);
    $stmt->execute();
    $items = $stmt->fetchAll(PDO::FETCH_ASSOC);

    echo json_encode([
        "status" => "success",
        "items" => $items
    ]);
} catch (PDOException $e) {
    echo json_encode([
        "status" => "error",
        "message" => "Feed query failed: " . $e->getMessage()
    ]);
}
?>