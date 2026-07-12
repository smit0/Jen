FROM alpine:latest

# Install a lightweight web server
RUN apk add --no-cache apache2

# Create the document root
RUN mkdir -p /var/www/html

# Create index.html
RUN cat > /var/www/html/index.html <<'EOF'
<!DOCTYPE html>
<html>
<head>
    <title>Jagsonpal</title>
</head>
<body style="background-color:skyblue;">
    <h1 style="background-color:brown;">This is Application Server 1</h1>
    <h2 style="background-color:green;">Hello, Welcome to JAGSONPAL.</h2>
</body>
</html>
EOF

# Expose HTTP port
EXPOSE 80

# Run Apache in the foreground
CMD ["/usr/sbin/httpd", "-D", "FOREGROUND"]