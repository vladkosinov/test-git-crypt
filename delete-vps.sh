#!/bin/bash

IAM_TOKEN=$(
    curl -s -d "{\"yandexPassportOauthToken\":\"${YC_TOKEN}\"}" \
    https://iam.api.cloud.yandex.net/iam/v1/tokens |\
    jq --raw-output .iamToken
)

VPS_ID=$(
    curl -s -H "Authorization: Bearer ${IAM_TOKEN}" \
    https://compute.api.cloud.yandex.net/compute/v1/instances\?folder_id\=${YC_FOLDER_ID} |\
    jq --raw-output '.instances[]? | select(.name == "vpn-machine").id'
)

if [ -n "$VPS_ID" ]; then
    echo "Found VPS, deleting..."
    timeout --foreground 300s bash <<EOT

    OPERATION_ID=\$(
        curl -s -X DELETE -H "Authorization: Bearer ${IAM_TOKEN}" \
        https://compute.api.cloud.yandex.net/compute/v1/instances/${VPS_ID} |\
        jq --raw-output '.id'
    )

    while true; do
        OPERATION_STATUS=\$(
            curl -s -H "Authorization: Bearer ${IAM_TOKEN}" \
            https://operation.api.cloud.yandex.net/operations/\${OPERATION_ID} |\
            jq --raw-output '.done'
        )
        echo "Yandex answer, deletion status: \$OPERATION_STATUS"

        if [ "\$OPERATION_STATUS" == 'true' ]; then
            echo "Finally deleted"
            break
        fi

        echo "Waiting 2s more..."
        sleep 2
    done
EOT
    if [ $? -ne 0 ]; then
        echo "Failed deleting VPS"
        exit 1
    fi
else
    echo "No VPS to delete"
fi
