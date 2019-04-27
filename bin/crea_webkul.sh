#!/bin/bash
sudo useradd webkul
sudo usermod --groups webkul,wheel,nginx webkul
echo "webkul:webkul123" | sudo chpasswd
