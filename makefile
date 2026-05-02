.PHONY: install start stop logs status

install:
	@echo "Installing..."
	chmod +x install.sh
	./install.sh

start:
	@echo "Starting rclone-over-autossh..."
	systemctl start rclone.service
	systemctl start autossh.service

stop:
	@echo "Stopping rclone-over-autossh..."
	systemctl stop rclone.service
	systemctl stop autossh.service

restart:
	@echo "Restarting services..."
	systemctl restart rclone.service
	systemctl restart autossh.service

logs:
	@echo "=== Last 20 lines of logs ==="
	@echo "\n--- rclone.service logs ---"
	journalctl -u rclone.service -n 20 --no-pager
	@echo "\n--- autossh.service logs ---"
	journalctl -u autossh.service -n 20 --no-pager

uninstall:
	@echo "Cleaning up..."
	systemctl stop rclone.service autossh.service 2>/dev/null || true
	systemctl disable rclone.service autossh.service 2>/dev/null || true
	rm -f /etc/systemd/system/rclone.service
	rm -f /etc/systemd/system/autossh.service
	systemctl daemon-reload