settings:
  clusterName: ${cluster_name}
  clusterCIDR: "172.20.0.0/16"
  clusterEndpoint: ${cluster_endpoint}
  interruptionQueue: ${interruption_queue_name}

controller:
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${controller_role_arn}

tolerations:
  - key: "CriticalAddonsOnly"
    operator: "Equal"
    value: "true"
    effect: "NoSchedule"

nodeSelector:
  intent: "control-plane"          