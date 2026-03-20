<?php
try {
    $dbh = new PDO('mysql:host=localhost;dbname=test', $user, $password);
    foreach($dbh->query('SELECT * FROM test.jeux_video') as $row) {
        print_r($row);
    }
    $dbh = null;
} catch (PDOException $e) {
    print "Erreur !: " . $e->getMessage() . "<br/>";
    die();
}
?>
