# Use Python 3.11-slim for smaller image size (FREE TIER optimized)
FROM python:3.11-slim

# Set environment variables for production
ENV PYTHONDONTWRITEBYTECODE=1
ENV PYTHONUNBUFFERED=1

# Set working directory
WORKDIR /app

# Install only essential system packages
RUN apt-get update && apt-get install -y --no-install-recommends \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements first to leverage Docker cache
COPY requirements.txt .

# Install Python dependencies with optimization for smaller footprint
RUN pip install --no-cache-dir --user -r requirements.txt

# Copy the application code
COPY main.py .
COPY static/ ./static/

# Expose the port the app runs on
EXPOSE 8080

# Run the application
CMD ["python", "main.py"]