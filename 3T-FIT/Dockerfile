# Use an official Python runtime as a parent image
FROM python:3.13-slim

# Set the working directory in the container
WORKDIR /app

# Copy the requirements file into the container at /app
COPY requirements.txt .

# Install any needed packages specified in requirements.txt
RUN pip install --no-cache-dir -r requirements.txt

# Copy the ai_server directory into the container at /app/ai_server
COPY ai_server ./ai_server

# Set the PYTHONPATH to include the current directory
ENV PYTHONPATH=/app:/app/ai_server/app

# Expose port 8888
EXPOSE 8888

# Run app.main:app when the container launches
CMD ["uvicorn", "ai_server.app.main:app", "--host", "0.0.0.0", "--port", "8888", "--reload"]