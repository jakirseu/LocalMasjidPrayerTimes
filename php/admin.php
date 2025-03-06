<?php
session_start();
$config = include 'config.php';

if (isset($_POST['username']) && isset($_POST['password'])) {
    if ($_POST['username'] === $config['admin_username'] && $_POST['password'] === $config['admin_password']) {
        $_SESSION['admin'] = true;
    } else {
        echo "<div class='alert alert-danger text-center'>Incorrect Username or Password!</div>";
    }
}

if (isset($_GET['logout'])) {
    session_destroy();
    header("Location: admin.php");
    exit();
}

$dataFile = "data.json";
$data = file_exists($dataFile) ? json_decode(file_get_contents($dataFile), true) : [];

if (!isset($_SESSION['admin'])) {
?>
    <?php include 'header.php'; ?>
    <div class="container py-5">
        <div class="row justify-content-center">
            <div class="col-md-4">
                <div class="card shadow">
                    <div class="card-body">
                        <h3 class="text-center">Admin Login</h3>
                        <form method="POST">
                            <div class="mb-3">
                                <input type="text" name="username" class="form-control" placeholder="Enter Admin Username" required>
                            </div>
                            <div class="mb-3">
                                <input type="password" name="password" class="form-control" placeholder="Enter Admin Password" required>
                            </div>
                            <button type="submit" class="btn btn-primary w-100">Login</button>
                        </form>
                    </div>
                </div>
            </div>
        </div>
    </div>
    <?php include 'footer.php'; ?>
<?php
    exit();
}
?>

<?php include 'header.php'; ?>

<div class="container py-5">
    <div class="card shadow-lg">
        <div class="card-body">
            <h2 class="text-center">Admin Dashboard</h2>
            <form method="POST" action="save.php" class="mt-4">
                <!-- Google Map URL input for Latitude and Longitude -->
                <div class="mb-3">
                    <label class="form-label">Google Map URL for Latitude ( <?= $data['latitude'] ?? '' ?>) and Longitude (<?= $data['longitude'] ?? '' ?>):    </label>
                    <input type="text" name="map_url" class="form-control" value="<?= $data['map_url'] ?? '' ?>" required>
                </div>

                <h4>Jamat Times:</h4>
                <?php
                $prayers = ["Fajr", "Dhuhr", "Asr", "Maghrib", "Isha", "Jumuah"];
                foreach ($prayers as $prayer):
                ?>
                    <div class="mb-3">
                        <label class="form-label"><?= $prayer ?>:</label>
                        <input type="time" name="<?= strtolower($prayer) ?>" class="form-control"
                               value="<?= $data['jamat'][$prayer] ?? '' ?>" required>
                    </div>
                <?php endforeach; ?>

                <!-- Dua of the Day -->
                <div class="mb-3">
                    <label class="form-label">Dua of the Day:</label>
                    <input type="text" name="dua_of_the_day" class="form-control" value="<?= $data['dua_of_the_day'] ?? '' ?>" required>
                </div>

                <!-- Hadith of the Day -->
                <div class="mb-3">
                    <label class="form-label">Hadith of the Day:</label>
                    <input type="text" name="hadith_of_the_day" class="form-control" value="<?= $data['hadith_of_the_day'] ?? '' ?>" required>
                </div>

                <!-- Quran Ayat of the Day -->
                <div class="mb-3">
                    <label class="form-label">Quran Ayat of the Day:</label>
                    <input type="text" name="quran_ayat_of_the_day" class="form-control" value="<?= $data['quran_ayat_of_the_day'] ?? '' ?>" required>
                </div>

                <button type="submit" class="btn btn-success w-100">Save</button>
            </form>

            <div class="text-center mt-3">
                <a href="admin.php?logout=true" class="btn btn-danger">Logout</a>
            </div>
        </div>
    </div>
</div>

<?php include 'footer.php'; ?>
