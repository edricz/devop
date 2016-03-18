#!/bin/bash -e
#
# BRICKLY.IO CONFIDENTIAL
# ______________________________
#
#  [2015] - [2016] Brickly.Io Incorporated
#  All Rights Reserved.
#
# NOTICE: All information contained herein is, and remains the property of Brickly.Io Incorporated
# and its suppliers, if any.  The intellectual and technical concepts contained herein are
# proprietary to Brickly.Io Incorporated and its suppliers and may be covered by U.S. and Foreign
# Patents, patents in process, and are protected by trade secret or copyright law. Dissemination of
# this information or reproduction of this material is strictly forbidden unless prior written
# permission is obtained from Brickly.Io Incorporated.
#

bin_dir=$(dirname $(readlink -f $0))
python_bin=/usr/local/bin/python3
s3ql_bin_dir=/usr/local/bin
timestamp=$(date +%Y-%m-%d_%H:%M:%S)

prep() {

    if (($# > 0)); then
        MOUNT_DIR=$1
        CACHE_DIR=$2
        AWS_ACCESS_KEY_ID=$3
        AWS_SECRET_ACCESS_KEY=$4
        FS_PATH=$5
        FS_LABEL=$6
        FS_PASSPHRASE=$7
    fi

    if [ -z ${MOUNT_DIR} ] ||
       [ -z ${CACHE_DIR} ] ||
       [ -z ${AWS_ACCESS_KEY_ID} ] ||
       [ -z ${AWS_SECRET_ACCESS_KEY} ]  ||
       [ -z ${FS_PATH} ] ||
       [ -z ${FS_LABEL} ] ||
       [ -z ${FS_PASSPHRASE} ]; then
        echo >&2 'Usage: <mount_dir> <cache_dir> <aws_access_id> <aws_access_secret> <fs_path> <fs_label> <fs_passphrase>'
        exit 1
    fi

    auth_file="/data/authinfo"
    log_file="/data/s3ql.log"

    mkdir -p $MOUNT_DIR
    mkdir -p $CACHE_DIR

    s3_path="s3://${FS_PATH}/${FS_LABEL}/"

    # generate credential file
    cat > "$auth_file" <<-EOSQL
[s3]
backend-login: ${AWS_ACCESS_KEY_ID}
backend-password: ${AWS_SECRET_ACCESS_KEY}
storage-url: s3://
fs-passphrase: ${FS_PASSPHRASE}
EOSQL
    chmod 0400 $auth_file

    if [ -z "${FS_CACHE_SIZE+x}" ] || [ "${FS_CACHE_SIZE}" = 0 ] ; then
        FS_CACHE_SIZE=$(($(df -k ${CACHE_DIR} |tail -n 1 |awk '{print $2}') / 2))
    fi
    fs_cache_size=${FS_CACHE_SIZE}
}

flush() {
    # flush the file system
    cd /
    echo "${python_bin} ${s3ql_bin_dir}/s3qlctrl flushcache ${mount_dir}"
    ${python_bin} ${s3ql_bin_dir}/s3qlctrl flushcache ${mount_dir}
    echo "${python_bin} ${s3ql_bin_dir}/s3qlctrl upload-meta ${mount_dir}"
    ${python_bin} ${s3ql_bin_dir}/s3qlctrl upload-meta ${mount_dir}
}

action=$1
shift

if [ "$action" = "mkfs" ] ; then
    # create file system
    prep $*
    printf "${FS_PASSPHRASE}\n${FS_PASSPHRASE}\n" | mkfs.s3ql --cachedir ${CACHE_DIR} --authfile ${auth_file} --backend-options no-ssl --max-obj-size 1024 -L ${FS_LABEL} ${s3_path}

elif [ "$action" = "fsck" ] ; then
    prep $*
    printf "continue\n" | fsck.s3ql --force --cachedir ${CACHE_DIR} --authfile ${auth_file} --backend-options no-ssl --log ${log_file} ${s3_path}

elif [ "$action" = "mount" ] ; then
    prep $*
    ulimit -n 100000
    printf "continue\n" | fsck.s3ql --cachedir ${CACHE_DIR} --authfile ${auth_file} --backend-options no-ssl --log ${log_file} ${s3_path} || true
    mount.s3ql --allow-other --cachedir ${CACHE_DIR} --authfile ${auth_file} --backend-options no-ssl --log ${log_file} --cachesize ${FS_CACHE_SIZE} ${s3_path} ${MOUNT_DIR}

    # remove any fsck recovered file since they will not be restored
    rm -rf ${MOUNT_DIR}/lost+found/*

elif [ "$action" = "umount" ] ; then
    prep $*
    sync
    s3qlctrl flushcache ${MOUNT_DIR}
    umount.s3ql ${MOUNT_DIR}

elif [ "$action" = "purge" ] ; then
    prep $*
    printf "yes\n" | s3qladm --authfile ${auth_file} --backend-options no-ssl clear ${s3_path}

elif [ "$action" = "install" ]; then
    mount_dir=$1
    src_dir=$2
    action=${3:-backup}
    mkdir -p /etc/cron.d
    cronfile=/etc/cron.d/${action}-$(/usr/bin/basename ${mount_dir})-cron
    echo "Installing ${action} job at ${mount_dir}/${src_dir}"
    echo "*/5 * * * * root ${bin_dir}/s3ql.sh ${action} ${mount_dir} ${src_dir} >> ${mount_dir}/${action}.log 2&>1" > ${cronfile}
    echo "# blank line" >> ${cronfile}
    chmod 0644 ${cronfile}

    if [ ! -e /var/run/crond.pid ]; then
        if ! /usr/sbin/cron; then /usr/sbin/cron; fi
    fi

elif [ "$action" = "backup" ] ; then
    mount_dir=$1
    src_dir=$2
    echo "Starting backup at ${timestamp}: $mount_dir $src_dir"

    # create a new backup
    mkdir -p ${mount_dir}/.backup
    echo "${python_bin} ${s3ql_bin_dir}/s3qlcp ${mount_dir}/${src_dir} ${mount_dir}/.backup/$timestamp"
    ${python_bin} ${s3ql_bin_dir}/s3qlcp ${mount_dir}/${src_dir} ${mount_dir}/.backup/$timestamp

    # expire old backups
    cd ${mount_dir}/.backup
    echo "${python_bin} ${s3ql_bin_dir}/expire_backups.py --use-s3qlrm 1 2 4 8 16 32 64 128 256 512 1024 2048"
    failed=0
    ${python_bin} ${s3ql_bin_dir}/expire_backups.py --use-s3qlrm 1 2 4 8 16 32 64 128 256 512 1024 2048 || failed=1
    if [ $failed != 0 ]; then
        echo "Rebuilding backup states"
        ${python_bin} ${s3ql_bin_dir}/expire_backups.py --reconstruct-state --use-s3qlrm 1 2 4 8 16 32 64 128 256 512 1024 2048
    fi

    flush
    echo "Done"

elif [ "$action" = "flush" ] ; then
    mount_dir=$1
    echo "Starting flush at ${timestamp}"
    flush
    echo "Done"

else
    echo >&2 'error: action parameter "[mkfs|fsck|mount|umount|purge|backup]" missing"'
fi
