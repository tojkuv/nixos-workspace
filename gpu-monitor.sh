#!/bin/bash
# Simple GPU Monitor for NVIDIA RTX 3060

echo "=== NVIDIA RTX 3060 GPU Monitor ==="
echo ""

# Get GPU info
nvidia-smi --query-gpu=name,memory.used,memory.total,utilization.gpu,utilization.memory,temperature.gpu,fan.speed,power.draw --format=csv,noheader,nounits | while IFS=',' read name mem_used mem_total util_gpu util_mem temp fan power; do
    echo "GPU Name: $name"
    echo "Memory: ${mem_used}MB / ${mem_total}MB"
    echo "GPU Utilization: ${util_gpu}%"
    echo "Memory Utilization: ${util_mem}%"
    echo "Temperature: ${temp}°C"
    echo "Fan Speed: ${fan}%"
    echo "Power Draw: ${power}W"
    echo ""
done

# Show running processes
echo "=== GPU Processes ==="
nvidia-smi --query-compute-apps=pid,name,used_memory --format=csv,noheader | while IFS=',' read pid name mem; do
    if [ "$pid" != "pid" ]; then
        echo "PID: $pid | Process: $name | Memory: $mem"
    fi
done

echo ""
echo "Press Ctrl+C to exit"
echo "Run with: watch -n 1 $0  # For real-time updates"