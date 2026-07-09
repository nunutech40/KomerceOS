# Start with the base Flutter image
FROM cirrusci/flutter:latest

# Set Flutter to use the stable channel and upgrade
RUN flutter channel stable && flutter upgrade && flutter doctor
