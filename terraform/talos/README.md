## Talos Kubernetes Setup

1. Update the controlplane endpoint in `cluster.controlPlane.endpoint` of both `controlplane.yaml` and `worker.yaml`
2. Apply the coinfiguration to controlplane nodes
```bash
talosctl apply-config --insecure --nodes $CONTROL_PLANE_IP[1-3] --file controlplane.yaml"
```

3. Apply the coinfiguration to worker nodes
```bash
talosctl apply-config --insecure --nodes $WORKER_IP[1-3] --file worker.yaml"
```

4. Update the `talosconfig` file with the controlplane endpoint
```bash
talosctl config endpoint $CONTROL_PLANE_IP
talosctl config node $CONTROL_PLANE_IP
```

5. Bootstraping the cluster and retrieve the kubeconfig
```bash
talosctl bootstrap
talosctl kubeconfig .
```
