echo "Getting Configurations..."

BASE_LOG_FOLDER=$1
MAX_LOG_SIZE=$2
ENABLE_DELETE=$3

echo "Finished Getting Configurations"
echo ""

echo "Configurations:"
echo "BASE_LOG_FOLDER:      '${BASE_LOG_FOLDER}'"
echo "MAX_LOG_SIZE:         '${MAX_LOG_SIZE}'"
echo "ENABLE_DELETE:        '${ENABLE_DELETE}'"

cleanup() {
    echo "Executing Find Statement: $1"
    FILES_MARKED_FOR_DELETE=$(eval $1)
    echo "Process will be Deleting the following files or directories:"
    echo "${FILES_MARKED_FOR_DELETE}"
    echo "Process will be Deleting $(echo "${FILES_MARKED_FOR_DELETE}" |
        grep -v '^$' | wc -l) files or directories"
    # "grep -v '^$'" - removes empty lines.
    # "wc -l" - Counts the number of lines
    echo ""
    if [ "${ENABLE_DELETE}" == "true" ]; then
        if [ "${FILES_MARKED_FOR_DELETE}" != "" ]; then
            echo "Executing Delete Statement: $2"
            eval $2
            DELETE_STMT_EXIT_CODE=$?
            if [ "${DELETE_STMT_EXIT_CODE}" != "0" ]; then
                echo "Delete process failed with exit code  '${DELETE_STMT_EXIT_CODE}'"

                exit ${DELETE_STMT_EXIT_CODE}
            fi
        else
            echo "WARN: No files or directories to Delete"
        fi
    else
        echo "WARN: You're opted to skip deleting the files or directories"
    fi
}

echo ""
echo "Running Cleanup Process..."

FIND_STATEMENT="find ${BASE_LOG_FOLDER} -type f -size +${MAX_LOG_SIZE}"
DELETE_STMT="${FIND_STATEMENT} -exec rm -f {} \;"

cleanup "${FIND_STATEMENT}" "${DELETE_STMT}"
CLEANUP_EXIT_CODE=$?

FIND_STATEMENT="find ${BASE_LOG_FOLDER} -type d -empty"
DELETE_STMT="${FIND_STATEMENT} -prune -exec rm -rf {} \;"

cleanup "${FIND_STATEMENT}" "${DELETE_STMT}"
CLEANUP_EXIT_CODE=$?

FIND_STATEMENT="find ${BASE_LOG_FOLDER} -type d -empty"
DELETE_STMT="${FIND_STATEMENT} -prune -exec rm -rf {} \;"

cleanup "${FIND_STATEMENT}" "${DELETE_STMT}"
CLEANUP_EXIT_CODE=$?

echo "Finished Running Cleanup Process"
