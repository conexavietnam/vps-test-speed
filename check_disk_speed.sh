#!/bin/bash

echo "----------------------------------------"
echo "   ĐANG KIỂM TRA TỐC ĐỘ Ổ ĐĨA... VUI LÒNG CHỜ"
echo "----------------------------------------"

# Cài fio nếu chưa có
if ! command -v fio &> /dev/null
then
    echo "Cài đặt fio..."
    sudo apt update && sudo apt install -y fio
fi

# Test ghi
WRITE_RESULT=$(fio --name=test-write --ioengine=libaio --rw=randwrite --bs=4k --size=256M --numjobs=1 --runtime=10 --group_reporting 2>/dev/null | grep "bw=" | head -1)

# Test đọc
READ_RESULT=$(fio --name=test-read --ioengine=libaio --rw=read --bs=1M --size=512M --numjobs=1 --runtime=10 --group_reporting 2>/dev/null | grep "bw=" | head -1)

echo ""
echo ">> KẾT QUẢ TỐC ĐỘ GHI:"
echo "$WRITE_RESULT"
echo ""
echo ">> KẾT QUẢ TỐC ĐỘ ĐỌC:"
echo "$READ_RESULT"

# Đánh giá đơn giản
echo ""
echo ">> ĐÁNH GIÁ SƠ BỘ:"

READ_MB=$(echo "$READ_RESULT" | grep -oP '[0-9]+(?=MiB/s)' | head -1)
if [ "$READ_MB" -ge 1000 ]; then
    echo "Ổ cứng của bạn có thể là SSD NVMe (Tốc độ cao trên 1000MB/s)"
elif [ "$READ_MB" -ge 300 ]; then
    echo "Ổ cứng của bạn có thể là SSD SATA (Tốc độ tầm trung)"
else
    echo "Ổ cứng có thể là HDD hoặc ảo hóa chậm (Tốc độ thấp)"
fi

echo "----------------------------------------"
