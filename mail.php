<?php
header('Content-Type: application/json');
header('Access-Control-Allow-Origin: *');

if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo json_encode(['ok' => false]);
    exit;
}

/* ── Gmail SMTP config ── */
define('SMTP_HOST', 'smtp.gmail.com');
define('SMTP_PORT', 587);
define('SMTP_USER', 'siterounds@gmail.com');
define('SMTP_PASS', 'vssyinutgmxvsfoy');
define('MAIL_TO',   'rounds.academy@gmail.com');

/* ── Minimal SMTP sender (no library needed) ── */
function send_smtp($to, $subject, $body, $reply_to) {
    $socket = fsockopen('tcp://' . SMTP_HOST, SMTP_PORT, $errno, $errstr, 15);
    if (!$socket) return false;

    $read = function () use ($socket) {
        $d = '';
        while ($s = fgets($socket, 515)) {
            $d .= $s;
            if ($s[3] === ' ') break;
        }
        return $d;
    };
    $cmd = function ($c) use ($socket) { fputs($socket, $c . "\r\n"); };

    $read();
    $cmd('EHLO localhost'); $read();
    $cmd('STARTTLS');       $read();

    stream_socket_enable_crypto($socket, true, STREAM_CRYPTO_METHOD_TLS_CLIENT);

    $cmd('EHLO localhost');     $read();
    $cmd('AUTH LOGIN');         $read();
    $cmd(base64_encode(SMTP_USER)); $read();
    $cmd(base64_encode(SMTP_PASS));
    $r = $read();
    if (strpos($r, '235') === false) { fclose($socket); return false; }

    $cmd('MAIL FROM: <' . SMTP_USER . '>'); $read();
    $cmd('RCPT TO: <' . $to . '>');         $read();
    $cmd('DATA');                            $read();

    $msg  = "From: Rounds Academy <" . SMTP_USER . ">\r\n";
    $msg .= "Reply-To: $reply_to\r\n";
    $msg .= "To: $to\r\n";
    $msg .= "Subject: $subject\r\n";
    $msg .= "Content-Type: text/plain; charset=UTF-8\r\n";
    $msg .= "\r\n";
    $msg .= $body;

    $cmd($msg . "\r\n."); $read();
    $cmd('QUIT');
    fclose($socket);
    return true;
}

/* ── Parse form fields ── */
$to = MAIL_TO;

if (isset($_POST['nome'])) {
    $nome     = htmlspecialchars(trim($_POST['nome']    ?? ''));
    $apelido  = htmlspecialchars(trim($_POST['apelido'] ?? ''));
    $email    = filter_var(trim($_POST['email']         ?? ''), FILTER_SANITIZE_EMAIL);
    $code     = htmlspecialchars(trim($_POST['phone-code'] ?? ''));
    $telefone = htmlspecialchars(trim($_POST['telefone'] ?? ''));
    $aula     = htmlspecialchars(trim($_POST['aula']    ?? ''));
    $mensagem = htmlspecialchars(trim($_POST['mensagem'] ?? ''));

    $subject = 'Novo Pedido de Inscrição — Rounds Academy';
    $body  = "Nome: $nome $apelido\n";
    $body .= "Email: $email\n";
    $body .= "Telefone: $code $telefone\n";
    $body .= "Aula de interesse: $aula\n";
    if ($mensagem) $body .= "Mensagem: $mensagem\n";
} else {
    $fname   = htmlspecialchars(trim($_POST['fname']   ?? ''));
    $lname   = htmlspecialchars(trim($_POST['lname']   ?? ''));
    $email   = filter_var(trim($_POST['email']         ?? ''), FILTER_SANITIZE_EMAIL);
    $code    = htmlspecialchars(trim($_POST['phone-code'] ?? ''));
    $phone   = htmlspecialchars(trim($_POST['phone']   ?? ''));
    $message = htmlspecialchars(trim($_POST['message'] ?? ''));

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

$sent = send_smtp($to, $subject, $body, $email);
echo json_encode(['ok' => $sent]);
