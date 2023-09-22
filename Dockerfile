FROM nyamisty/docker-wine-dotnet:win32-devel-7.2

# Define RVTools installer file name
ARG RVToolsFile=RVTools4.2.2.msi

LABEL maintainer="Angelo GERARD from CANAL+ Télécom System DevOps & Automation Team"

RUN mkdir -p /app

WORKDIR "/app"

# Install prerequisites
RUN apt-get update \
    && DEBIAN_FRONTEND="noninteractive" apt-get install -y --no-install-recommends \
        sendmail \
        sharutils \
		locales \
        gettext \
    && rm -rf /var/lib/apt/lists/*

# Get environment variable file
COPY .env.sh /app/.env.sh

# Get mail message file
COPY .message.txt /app/.message.txt

# Load environment variable file
ENV BASH_ENV=/app/.env.sh

# Set SHELL to bash for running commands in the virtual environment
SHELL ["/bin/bash", "-c"]

# Download RVTools installer
COPY ${RVToolsFile} /app/${RVToolsFile}

# Change access permissions for RVTools installer to allow it to be executed
RUN chmod +x /app/${RVToolsFile}

# Download RVTools script
COPY rvt-gen-script.sh /app/rvt-gen-script.sh

# Install RVTools
RUN wine msiexec /i ./${RVToolsFile} /quiet

# Set the locale
RUN sed -i '/fr_FR.UTF-8/s/^# //g' /etc/locale.gen \
    && locale-gen
ENV TZ "Europe/Paris"
ENV LANG fr_FR.UTF-8
ENV LANGUAGE fr_FR:fr
ENV LC_ALL fr_FR.UTF-8

# Complete sendmail config file
RUN sed -z 's|MAILER_DEFINITIONS\nMAILER(`local\x27)dnl|MAILER_DEFINITIONS\ndefine(`SMART_HOST\x27,`['"${SMTPserver}"']\x27)dnl\ndefine(`RELAY_MAILER_ARGS\x27, `TCP $h 25\x27)dnl\ndefine(`ESMTP_MAILER_ARGS\x27, `TCP $h 25\x27)dnl\ndefine(`confAUTH_OPTIONS\x27, `A p\x27)dnl\nFEATURE(`authinfo\x27,`hash -o /etc/mail/authinfo/smtp-auth.db\x27)dnl\nMAILER(`local\x27)dnl|g' -i /etc/mail/sendmail.mc \
    # Compile sendmail config file
    && make -C /etc/mail

# Change access permissions for RVTools script to allow it to be executed
RUN chmod +x /app/rvt-gen-script.sh

# Set the entrypoint of the Docker image
ENTRYPOINT ./rvt-gen-script.sh
