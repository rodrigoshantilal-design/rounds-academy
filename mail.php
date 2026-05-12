<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false]);
    exit;
}

$to = 'rounds.academy@gmail.com';

// Detect which form was submitted
if (isset($_POST['nome'])) {
    // Landing page form
    $nome     = htmlspecialchars(trim($_POST['nome'] ?? ''));
    $apelido  = htmlspecialchars(trim($_POST['apelido'] ?? ''));
    $email    = filter_var(trim($_POST['email'] ?? ''), FILTER_SANITIZE_EMAIL);
    $code     = htmlspecialchars(trim($_POST['phone-code'] ?? ''));
    $telefone = htmlspecialchars(trim($_POST['telefone'] ?? ''));
    $aula     = htmlspecialchars(trim($_POST['aula'] ?? ''));
    $mensagem = htmlspecialchars(trim($_POST['mensagem'] ?? ''));

    $subject = 'Novo Pedido de Inscrição — Rounds Academy';
    $body  = "Nome: $nome $apelido\n";
    $body .= "Email: $email\n";
    $body .= "Telefone: $code $telefone\n";
    $body .= "Aula de interesse: $aula\n";
    if ($mensagem) $body .= "Mensagem: $mensagem\n";
} else {
    // Contact page form
    $fname    = htmlspecialchars(trim($_POST['fname'] ?? ''));
    $lname    = htmlspecialchars(trim($_POST['lname'] ?? ''));
    $email    = filter_var(trim($_POST['email'] ?? ''), FILTER_SANITIZE_EMAIL);
    $code     = htmlspecialchars(trim($_POST['phone-code'] ?? ''));
    $phone    = htmlspecialchars(trim($_POST['phone'] ?? ''));
    $message  = htmlspecialchars(trim($_POST['message'] ?? ''));

    $subject = 'Nova Mensagem de Contacto — Rounds Academy';
    $body  = "Nome: $fname $lname\n";
    $body .= "Email: $email\n";
    $body .= "Telefone: $code $phone\n";
    $body .= "Mensagem: $message\n";
}

if (!$email) {
    http_response_code(400);
    echo json_encode(['ok' => false]);
    exit;
}

$headers  = "From: no-reply@roundsacademy.pt\r\n";
$headers .= "Reply-To: $email\r\n";
$headers .= "Content-Type: text/plain; charset=UTF-8\r\n";

$sent = mail($to, $subject, $body, $headers);

echo json_encode(['ok' => $sent]);
