FROM i386/alpine:3.20 AS build

LABEL maintainer="Angelo GERARD from CANAL+ Télécom System DevOps & Automation Team"

# Define RVTools installer file name
ENV RVToolsFile=RVTools4.2.2.msi

# Copy required files from host
COPY --chmod=0755 .env.sh .message.txt rvt-gen-script.sh ${RVToolsFile} ./

# Startup script with env variables to load user defined preferences and locale
RUN echo -e "export MUSL_LOCPATH=\"/usr/share/i18n/locales/musl\"\nexport WINEDEBUG=\"fixme-all\"" >> .env.sh \
    && cat .env.sh > /etc/profile.d/77rvtools.sh

# Load env variables by switching shell
SHELL ["/bin/sh", "-l", "-c"]

# Install template script
RUN echo -e "#!/usr/bin/awk -f\n{ for (a in ENVIRON) gsub(\"{{\" _ a _ \"}}\", ENVIRON[a]); print }" > /usr/bin/envtmpl \
    && chmod +x /usr/bin/envtmpl

# Install msmtp configuration file
RUN echo -e "defaults\nport {{SMTPport}}\naccount myrvtools\nhost {{SMTPserver}}\nfrom {{Mailfrom}}\naccount default : myrvtools" | envtmpl > $HOME/.msmtprc \
    && chmod 600 $HOME/.msmtprc

# Install Wine, msmtp and dependencies
RUN apk add --no-cache --update wine=9.0-r0 xvfb-run=1.20.10.3-r2 msmtp=1.8.26-r0 gnutls=3.8.5-r0 uuidgen=2.40.1-r1 libintl=0.22.5-r0 tzdata=2025a-r0 musl-locales=0.1.0-r1 \
    && rm -rf /var/cache/apk/* /tmp/*

# Setup a Wine prefix with .NET
RUN apk add --no-cache winetricks=20250102-r0 --repository=http://dl-cdn.alpinelinux.org/alpine/edge/testing/ \
    && winecfg && wineboot -u \
    && winetricks -q dotnet48 \
    && wineserver -k \
    && apk del winetricks \
    && rm -rf $HOME/.cache/winetricks $HOME/.cache /var/cache/apk/* /tmp/*

# Install RVTools
RUN wine msiexec /i ${RVToolsFile} /quiet \
    && rm -rf ${RVToolsFile} /var/cache/apk/* /tmp/*

# Cleaning file system (including unused Windows DLLs) to create the most compact image possible
RUN cd $HOME/.wine/drive_c/windows/Microsoft.NET/assembly/GAC_MSIL && rm -rf PresentationFramework System.Design Microsoft.Build Microsoft.Build.Tasks.v4.0 && cd - && rm -rf $HOME/.wine/drive_c/windows/Microsoft.NET/NETFXRepair.* $HOME/.wine/drive_c/users/root/Temp $HOME/.wine/drive_c/windows/Installer && rm -rf /usr/lib/gstreamer-1.0 && cd $HOME/.wine/drive_c/Program\ Files/Robware/RVTools && rm EULA.rtf RVTools.pdf RVToolsMergeExcelFiles.exe RVToolsMergeExcelFiles.exe.config RVToolsSendMail.exe RVToolsSendMail.exe.config RVToolsPasswordEncryption.exe RVToolsPasswordEncryption.exe.config RVToolsBatchMultipleVCs.ps1 ICSharpCode.SharpZipLib.dll && cd - && rm -rf $HOME/.wine/drive_c/windows/Microsoft.NET/Framework/v4.0.30319/SetupCache && rm -rf $HOME/.wine/drive_c/windows/assembly && cd /usr/lib/wine/i386-windows && ls | grep -E "jscript.dll|winmm.dll|atl100.dll|msvfw32.dll|quartz.dll|cryptdlg.dll|devenum.dll|qcap.dll|qedit.dll|urlmon.dll|winegstreamer.dll|compstui.dll|winspool.drv|wineps.drv|winprint.dll|.exe16$|.dll16$|comctl32.dll|msi.dll|windowscodecs.dll|cryptui.dll|oleaut32.dll|^msvcr\d|^x3daudio|^xinput|^msvcp|^d3d|^xaudio|^xactengine|wldap32.dll|mshtml.dll|wined3d.dll|msxml3.dll|light.msstyles|comdlg32.dll|opengl32.dll|actxprxy.dll" | xargs rm && ls | grep -Ev ".drv$|.dll$|wineboot.exe|winecfg.exe|start.exe|rundll32.exe|services.exe|explorer.exe" | xargs rm && cd -

# Create a lightweight single layer image using multi-stage build to clear deleted files from final build
FROM scratch

# Copy all files from build
COPY --from=build / /

# Load env variables by switching shell
SHELL ["/bin/sh", "-l", "-c"]

# Entrypoint script to run RVTools
ENTRYPOINT ./rvt-gen-script.sh
