#!/bin/bash
# ==============================================================================
# Script Backup Otomatis - Sysadmin / DevOps Support Assessment
# Target: WordPress (wp.wara.efs.my.id) & Laravel (laravel.wara.efs.my.id)
# ==============================================================================

# 1. KONFIGURASI DIREKTORI & WAKTU
BACKUP_DIR="/backup"
TANGGAL=$(date +%Y%m%d_%H%M%S)
LOG_FILE="/var/log/backup_automation.log"

# Memastikan direktori backup tersedia di server
mkdir -p $BACKUP_DIR

echo "========================================================================" | tee -a $LOG_FILE
echo "=== MEMULAI PROSES BACKUP OTOMATIS: $(date) ===" | tee -a $LOG_FILE
echo "========================================================================" | tee -a $LOG_FILE

# 2. BACKUP DATABASE MYSQL (WordPress & Laravel)
echo "[1/3] Mendumping database MySQL..." | tee -a $LOG_FILE
mysqldump -u root wp_db > $BACKUP_DIR/wp_db_$TANGGAL.sql 2>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo " -> SUCCESS: Backup database wp_db berhasil." | tee -a $LOG_FILE
else
    echo " -> ERROR: Backup database wp_db GAGAL!" | tee -a $LOG_FILE
fi

mysqldump -u root laravel_db > $BACKUP_DIR/laravel_db_$TANGGAL.sql 2>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo " -> SUCCESS: Backup database laravel_db berhasil." | tee -a $LOG_FILE
else
    echo " -> ERROR: Backup database laravel_db GAGAL!" | tee -a $LOG_FILE
fi

# 3. BACKUP FILE WEBSITE DIREKTORI /var/www/
echo "[2/3] Mengompres file direktori website ke tar.gz..." | tee -a $LOG_FILE
tar -czf $BACKUP_DIR/wordpress-files-$TANGGAL.tar.gz -C /var/www wp.wara.efs.my.id 2>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo " -> SUCCESS: Kompresi berkas WordPress berhasil." | tee -a $LOG_FILE
else
    echo " -> ERROR: Kompresi berkas WordPress GAGAL!" | tee -a $LOG_FILE
fi

tar -czf $BACKUP_DIR/laravel-files-$TANGGAL.tar.gz -C /var/www laravel.wara.efs.my.id 2>>$LOG_FILE
if [ $? -eq 0 ]; then
    echo " -> SUCCESS: Kompresi berkas Laravel berhasil." | tee -a $LOG_FILE
else
    echo " -> ERROR: Kompresi berkas Laravel GAGAL!" | tee -a $LOG_FILE
fi

# 4. ROTASI BACKUP / RETENTION POLICY (Hapus file cadangan > 7 hari)
echo "[3/3] Menjalankan rotasi pencadangan (menghapus berkas lama > 7 hari)..." | tee -a $LOG_FILE
find $BACKUP_DIR -type f -mtime +7 -name "*.sql" -exec rm -f {} \; -print >> $LOG_FILE
find $BACKUP_DIR -type f -mtime +7 -name "*.tar.gz" -exec rm -f {} \; -print >> $LOG_FILE

echo "------------------------------------------------------------------------" | tee -a $LOG_FILE
echo "=== PROSES PENYIMPANAN CADANGAN SELESAI: $(date) ===" | tee -a $LOG_FILE
echo "Daftar file backup terbaru saat ini di $BACKUP_DIR:" | tee -a $LOG_FILE
ls -lh $BACKUP_DIR | tee -a $LOG_FILE
echo "========================================================================" | tee -a $LOG_FILE
echo "" >> $LOG_FILE
