if ! command -v zstd &> /dev/null; then
    echo "🔧 zstd not found. Installing..."
    apt-get update && apt-get install -y zstd
fi