# Quick Reference - Data Structures & Databases

## TL;DR - Recommended Stack

```
Frontend:  Flutter + SQLite/Hive (Local Cache)
Backend:   Node.js/Python/Go + REST API
Primary:   PostgreSQL (Relational, ACID)
Cache:     Redis (Sessions, Real-time)
Search:    Elasticsearch (Analytics)
Storage:   S3 (Files)
Queue:     RabbitMQ (Async Tasks)
```

## Data Models Checklist

### Core Models (Already Have)
- [x] User
- [x] Referral
- [x] Program
- [x] Transaction
- [x] Game
- [x] Mission
- [x] Leaderboard

### Missing Models (Add These)
- [ ] UserProfile (Extended)
- [ ] ReferralCampaign
- [ ] ReferralAnalytics
- [ ] Achievement/Badge
- [ ] AuditLog
- [ ] Notification
- [ ] Withdrawal
- [ ] Dispute/Complaint

## Database Comparison

| Feature | PostgreSQL | Firebase | MongoDB |
|---------|-----------|----------|---------|
| Best For | **Referral Apps** | MVP | Document Storage |
| ACID | ✅ | ⚠️ | ❌ |
| Cost | $ | $$$ | $$ |
| Scalability | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Complexity | Medium | Low | Medium |

## PostgreSQL Schema (Simplified)

```sql
-- Core Tables
users (id, email, phone, referralCode, earnings, level)
referrals (id, referrerId, refereeId, programId, status)
programs (id, universityId, name, earning)
transactions (id, userId, type, amount, status)
withdrawals (id, userId, amount, status, paymentMethod)

-- Engagement
achievements (id, name, criteria, rarity)
user_achievements (userId, achievementId, unlockedAt)
notifications (id, userId, type, isRead)

-- Compliance
audit_logs (id, userId, action, changes, timestamp)
```

## Redis Use Cases

```
Sessions:        user:{userId}:session
Leaderboard:     leaderboard:monthly (sorted set)
OTP:             otp:{email} (5 min TTL)
Rate Limit:      rate_limit:{userId}:{action}
Real-time Data:  referral:{id}:status
```

## Elasticsearch Use Cases

```
Search:          referrals_index (search by name, email)
Analytics:       transactions_index (financial analytics)
Activity:        activity_index (user behavior)
Timeline:        activity_timeline (chronological)
```

## API Endpoints (Essential)

```
Auth:
  POST   /api/v1/auth/register
  POST   /api/v1/auth/login
  POST   /api/v1/auth/refresh-token

Users:
  GET    /api/v1/users/me
  PUT    /api/v1/users/me
  POST   /api/v1/users/kyc

Referrals:
  GET    /api/v1/referrals
  POST   /api/v1/referrals
  GET    /api/v1/referrals/:id

Wallet:
  GET    /api/v1/wallet
  GET    /api/v1/transactions
  POST   /api/v1/withdrawals

Leaderboard:
  GET    /api/v1/leaderboard
  GET    /api/v1/leaderboard/rank
```

## Data Flow - Key Scenarios

### Referral Creation
```
User → App → API → PostgreSQL
              ↓
           Redis (cache)
              ↓
        Elasticsearch (index)
              ↓
          RabbitMQ (email)
```

### Withdrawal Processing
```
User → App → API → PostgreSQL
              ↓
          RabbitMQ (async)
              ↓
        Payment Gateway
              ↓
        Update Status
              ↓
        Send SMS/Email
```

### Real-time Leaderboard
```
User Completes Referral
         ↓
    PostgreSQL (update)
         ↓
    Redis (increment score)
         ↓
    WebSocket (broadcast)
         ↓
    All Clients Update UI
```

## Security Essentials

- [ ] JWT authentication with refresh tokens
- [ ] TLS/HTTPS for all communications
- [ ] Rate limiting (Redis)
- [ ] Input validation & sanitization
- [ ] SQL injection prevention (parameterized queries)
- [ ] CORS configuration
- [ ] Audit logging for all actions
- [ ] KYC/Verification for withdrawals
- [ ] Fraud detection (Elasticsearch patterns)
- [ ] GDPR compliance (data retention, deletion)

## Performance Targets

- API Response: < 200ms (p95)
- Database Query: < 50ms (p95)
- Leaderboard Update: < 100ms
- Notification Delivery: < 5 seconds
- Concurrent Users: 10,000+
- Uptime: 99.9%

## Implementation Priority

### Phase 1 (MVP)
1. PostgreSQL setup
2. REST API with auth
3. User registration
4. Referral creation
5. Basic transactions

### Phase 2 (Enhancement)
1. Redis caching
2. Real-time leaderboard
3. Withdrawal system
4. Email notifications
5. KYC verification

### Phase 3 (Scale)
1. Elasticsearch
2. Advanced analytics
3. Achievement system
4. Fraud detection
5. Performance optimization

## Cost Breakdown (Monthly)

```
PostgreSQL:    $15-100
Redis:         $10-50
Elasticsearch: $20-200
S3 Storage:    $5-50
RabbitMQ:      $10-50
API Server:    $20-200
─────────────────────
Total:         $80-650
```

## Common Mistakes to Avoid

❌ Using Firebase for financial transactions
❌ Storing passwords in plain text
❌ No audit logs for compliance
❌ Missing rate limiting
❌ No caching strategy
❌ Synchronous payment processing
❌ No data validation
❌ Missing error handling
❌ No monitoring/alerting
❌ Hardcoded API keys

## Tools & Libraries

**Backend:**
- Express.js / FastAPI / Go Gin
- Sequelize / SQLAlchemy / GORM
- Redis client library
- Elasticsearch client

**Frontend:**
- Provider (State Management) ✅
- Dio (HTTP Client)
- Hive (Local Storage)
- GetIt (Service Locator)

**DevOps:**
- Docker
- Kubernetes
- GitHub Actions
- Terraform

## Resources

- PostgreSQL Docs: https://www.postgresql.org/docs/
- Redis Docs: https://redis.io/documentation
- Elasticsearch Docs: https://www.elastic.co/guide/
- Flutter Best Practices: https://flutter.dev/docs
- REST API Design: https://restfulapi.net/

## Next Steps

1. Review this architecture with team
2. Validate database schema
3. Prototype API endpoints
4. Load test with expected volume
5. Plan infrastructure
6. Implement Phase 1
7. Iterate based on feedback

