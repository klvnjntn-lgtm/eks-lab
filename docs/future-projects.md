## Future Improvements & Roadmap

The current system is functional and resilient, but several enhancements would further improve security, scalability, and operational maturity.

---

### Custom Domain & HTTPS Enforcement

- Integrate Amazon Route 53 for domain management

- Use AWS Certificate Manager (ACM) for SSL/TLS certificates

- Configure Application Load Balancer to enforce HTTPS (443)

- Redirect all HTTP traffic to HTTPS

Impact:

- Encrypts all client-server communication

- Aligns with production security standards

---

### Observability Enhancement (Grafana)

- Integrate Grafana with CloudWatch metrics

- Build dashboards for ECS, ALB, and RDS

Impact:

- Improves real-time system visibility

- Enables faster debugging and performance analysis

---

### Auto Scaling Optimization

- Implement ECS Service Auto Scaling (CPU / request-based)
- Tune scaling thresholds based on load patterns

Impact:
- Improves performance under load
- Reduces unnecessary compute cost

---

### Cost Control & Budgeting

- Monthly budget enforced using AWS Budgets
- Alerts triggered at:
  - 80% actual spend
  - 100% forecasted spend
- Notifications via email

Impact:
- Prevents unexpected cost spikes
- Improves cost visibility during development

---

### Future Direction

If this system were to evolve further:

- Introduce blue-green deployments using AWS CodeDeploy for controlled traffic shifting
- Add caching layer (Redis) to reduce database load
- Implement WAF for application-layer protection
- Explore Kubernetes (EKS) for larger-scale or multi-team environments

These improvements would transition the system from a learning project into a production-grade platform capable of handling higher scale and stricter reliability requirements.

---