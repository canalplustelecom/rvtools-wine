#!/bin/sh
set -x

Mailpart=`uuidgen`
Mailpart_body=`uuidgen`
AttachmentDir=.
AttachmentDirWin="$(winepath -w $AttachmentDir)"
Attach="$AttachmentDir/$AttachmentFile"
message=`cat .message.txt | envtmpl`

echo "Generating the RVTools xlsx file..."
if (env WINEARCH=win32 WINEPREFIX=$(realpath ~/.wine32) DISPLAY=${DISPLAY} WINEDLLOVERRIDES="mscoree,mshtml=" xvfb-run wine wineboot && xvfb-run wineserver -w && xvfb-run wine cmd.exe /c "C:\Program Files\Robware\RVTools\RVTools.exe" -s $VCSAserver -u $VCSAuser -p $VCSAencryptedpass -c ExportAll2xlsx -d $AttachmentDirWin -f $AttachmentFile) ; then
    echo "Sending the RVTools xlsx file by email..."
    (
        echo "From: $Mailfrom"
        echo "To: $Mailto"
        echo "Cc: $Mailcc"
        echo "Subject: $Mailsubject"
        echo "MIME-Version: 1.0"
        echo "Content-Type: multipart/mixed; boundary=\"$Mailpart\""
        echo ""
        echo "--$Mailpart"
        echo "Content-Type: multipart/alternative; boundary=\"$Mailpart_body\""
        echo ""
        echo "--$Mailpart_body"
        echo "Content-Type: text/plain; charset=UTF-8"
        echo "Content-Disposition: inline"
        echo -e "
$message"
        echo "--$Mailpart_body--"

        echo "--$Mailpart"
        echo 'Content-Type: application/vnd.ms-excel; name="'$(basename $Attach)'"'
        echo "Content-Transfer-Encoding: uuencode"
        echo 'Content-Disposition: attachment; filename="'$(basename $Attach)'"'
        echo ""
        uuencode $Attach $(basename $Attach)
        echo "--$Mailpart--"
    ) | msmtp -t
    echo "[OK] The script was executed successfully"
else
    echo "[ERR] An error occurred while running the script"
fi
