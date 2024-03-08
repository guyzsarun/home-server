## Keycloak Setup

1. Create `oidc` realms in Keycloak
2. Import the clients under ./kubernetes/keycloak/clients
3. Create a user in the realm

### Minio Setup
Update the mapper from the [Minio Documentation](https://min.io/docs/minio/macos/operations/external-iam/configure-keycloak-identity-management.html)

### Grafana Setup
1. Add Realm roles
    - grafanaadmin
    - admin
    - editor
2. Role mapping to groups
