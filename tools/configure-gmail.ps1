param(
    [Parameter(Mandatory = $true)]
    [string]$Email
)

$ErrorActionPreference = 'Stop'
if ($Email -notmatch '^[^\s@]+@gmail\.com$') {
    throw 'Enter the Gmail address that will send contact replies.'
}

function Confirm-GmailSignIn([string]$address, [string]$password) {
    function Read-Reply([IO.StreamReader]$reader) {
        for ($lineNumber = 0; $lineNumber -lt 100; $lineNumber++) {
            $line = $reader.ReadLine()
            if ($null -eq $line -or $line -notmatch '^\d{3}[- ]') { throw 'Gmail closed the SMTP connection or returned an invalid response.' }
            if ($line[3] -eq ' ') { return $line.Substring(0, 3) }
        }
        throw 'Gmail returned too many SMTP response lines.'
    }
    function Send-Command([IO.StreamWriter]$writer, [string]$command) { $writer.WriteLine($command); $writer.Flush() }
    $connection = [Net.Sockets.TcpClient]::new()
    $reader = $null; $writer = $null; $tls = $null
    try {
        if (!$connection.ConnectAsync('smtp.gmail.com', 587).Wait(15000)) { throw 'Connection to Gmail timed out.' }
        $wire = $connection.GetStream(); $wire.ReadTimeout = 15000; $wire.WriteTimeout = 15000
        $reader = [IO.StreamReader]::new($wire, [Text.Encoding]::ASCII, $false, 1024, $true)
        $writer = [IO.StreamWriter]::new($wire, [Text.Encoding]::ASCII, 1024, $true); $writer.NewLine = "`r`n"
        if ((Read-Reply $reader) -ne '220') { throw 'Gmail did not accept the SMTP connection.' }
        Send-Command $writer 'EHLO localhost'
        if ((Read-Reply $reader) -ne '250') { throw 'Gmail rejected the SMTP greeting.' }
        Send-Command $writer 'STARTTLS'
        if ((Read-Reply $reader) -ne '220') { throw 'Gmail did not accept the encrypted connection request.' }
        $reader.Dispose(); $writer.Dispose()
        $tls = [Net.Security.SslStream]::new($wire, $true)
        $tls.ReadTimeout = 15000; $tls.WriteTimeout = 15000
        $tls.AuthenticateAsClient('smtp.gmail.com', $null, [Security.Authentication.SslProtocols]::Tls12, $true)
        $reader = [IO.StreamReader]::new($tls, [Text.Encoding]::ASCII, $false, 1024, $true)
        $writer = [IO.StreamWriter]::new($tls, [Text.Encoding]::ASCII, 1024, $true); $writer.NewLine = "`r`n"
        Send-Command $writer 'EHLO localhost'
        if ((Read-Reply $reader) -ne '250') { throw 'Gmail rejected the encrypted SMTP greeting.' }
        Send-Command $writer 'AUTH LOGIN'
        if ((Read-Reply $reader) -ne '334') { throw 'Gmail did not accept password authentication.' }
        Send-Command $writer ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($address)))
        if ((Read-Reply $reader) -ne '334') { throw 'Gmail rejected the sending account.' }
        Send-Command $writer ([Convert]::ToBase64String([Text.Encoding]::UTF8.GetBytes($password)))
        if ((Read-Reply $reader) -ne '235') {
            throw "Gmail rejected the app password for $address. Check the Google account shown when creating the password. No settings were changed."
        }
        Send-Command $writer 'QUIT'
        # Authentication only: no MAIL FROM, RCPT TO or DATA command is issued.
    }
    finally {
        if ($writer) { $writer.Dispose() }
        if ($reader) { $reader.Dispose() }
        if ($tls) { $tls.Dispose() }
        $connection.Dispose()
    }
}

Write-Host "Configure contact replies from $Email using Gmail TLS on port 587."
Write-Host 'Create an app password at https://myaccount.google.com/apppasswords first.'
Write-Host 'Enter the Google app password below, not your normal Google password.'
Write-Host 'Settings are saved in your Windows user environment for local IIS Express.'
Write-Host 'No email is sent by this setup script.'
$mailSecret = Read-Host 'Google app password (hidden)' -AsSecureString
$mailPointer = [IntPtr]::Zero
try {
    $mailPointer = [Runtime.InteropServices.Marshal]::SecureStringToBSTR($mailSecret)
    $mailPassword = [Runtime.InteropServices.Marshal]::PtrToStringBSTR($mailPointer) -replace '\s', ''
    if ($mailPassword -notmatch '^[a-zA-Z0-9]{16}$') {
        throw 'Expected a 16-character Google app password. No settings were changed.'
    }

    Write-Host 'Checking Gmail sign-in (no email will be sent)...'
    Confirm-GmailSignIn $Email $mailPassword
    Write-Host 'Gmail sign-in verified.'

    $mailSettings = @{
        UIMS_SMTP_HOST = 'smtp.gmail.com'
        UIMS_SMTP_PORT = '587'
        UIMS_SMTP_FROM = $Email
        UIMS_SMTP_USERNAME = $Email
        UIMS_SMTP_PASSWORD = $mailPassword
    }
    foreach ($mailSetting in $mailSettings.GetEnumerator()) {
        [Environment]::SetEnvironmentVariable($mailSetting.Key, $mailSetting.Value, 'User')
    }
    Write-Host 'Email settings saved. The password was not printed or written to the project.'
    Write-Host 'Close Visual Studio and IIS Express, reopen Visual Studio, and start the site again.'
    Write-Host 'Then retry the contact reply and confirm it arrives in the recipient inbox.'
}
finally {
    if ($mailPointer -ne [IntPtr]::Zero) {
        [Runtime.InteropServices.Marshal]::ZeroFreeBSTR($mailPointer)
    }
    if ($mailSettings) { $mailSettings.Clear() }
    $mailPassword = $null
    if ($mailSecret) { $mailSecret.Dispose() }
}
