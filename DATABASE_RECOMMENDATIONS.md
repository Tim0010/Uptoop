# Database Recommendations for Modern Referring App

## Architecture Overview

### Recommended Stack: **Hybrid Approach**

```
┌─────────────────────────────────────────────────────────┐
│                    Flutter App                          │
├─────────────────────────────────────────────────────────┤
│  Local Cache: SQLite / Hive (Offline-first)            │
├─────────────────────────────────────────────────────────┤
│              REST/GraphQL API Layer                     │
├─────────────────────────────────────────────────────────┤
│  Primary DB: PostgreSQL (Relational Core)              │
│  Cache Layer: Redis (Real-time, Sessions)              │
│  Search: Elasticsearch (Analytics, Referrals)          │
│  File Storage: S3/Cloud Storage (Avatars, Docs)        │
│  Message Queue: RabbitMQ/Kafka (Async Tasks)           │
└─────────────────────────────────────────────────────────┘
```

## Database Recommendations

### 1. **PostgreSQL** (Primary Database) ⭐ RECOMMENDED
**Why:**
- ACID compliance for financial transactions
- Complex relational queries (referral chains, analytics)
- JSON support for flexible metadata
- Full-text search capabilities
- Excellent for audit logs and compliance

**Schema Highlights:**
```sql
-- Core Tables
users (id, email, phone, referralCode, level, totalEarnings)
referrals (id, referrerId, refereeId, programId, status, earning)
programs (id, universityId, name, earning, isActive)
transactions (id, userId, type, amount, status, paymentMethod)
withdrawals (id, userId, amount, status, bankDetails)

-- Analytics
referral_analytics (referralId, source, conversionStage, timestamp)
user_activity (userId, action, timestamp, metadata)
audit_logs (userId, action, changes, timestamp, ipAddress)

-- Engagement
achievements (id, name, criteria, icon)
user_achievements (userId, achievementId, unlockedAt)
notifications (id, userId, type, isRead, createdAt)
```

### 2. **Redis** (Caching & Real-time) ⭐ RECOMMENDED
**Why:**
- Session management (JWT tokens)
- Real-time leaderboard updates
- Rate limiting & fraud detection
- Temporary data (OTP, verification codes)
- Pub/Sub for notifications

**Use Cases:**
```
- user:{userId}:session -> JWT token + metadata
- leaderboard:monthly -> Sorted set of top earners
- referral:{referralId}:status -> Real-time status updates
- otp:{email} -> Temporary OTP storage (5 min TTL)
- rate_limit:{userId}:{action} -> API rate limiting
```

### 3. **Elasticsearch** (Analytics & Search) ⭐ RECOMMENDED
**Why:**
- Fast referral search & filtering
- Analytics aggregations
- User activity timeline
- Fraud pattern detection
- Full-text search on descriptions

**Indices:**
```
- referrals_index: Search by friend name, email, status
- users_index: Search by name, email, school
- transactions_index: Financial analytics
- activity_index: User behavior tracking
```

### 4. **MongoDB** (Optional - Document Store)
**When to use:**
- If you need flexible schema for user metadata
- Complex nested data structures
- High write throughput for analytics

**Not recommended** for this app because:
- Financial transactions need ACID compliance
- Referral relationships are relational
- PostgreSQL JSON support is sufficient

### 5. **Firebase/Firestore** (Alternative - Simplified)
**Pros:**
- Quick MVP development
- Built-in authentication
- Real-time updates
- Automatic scaling

**Cons:**
- Limited query flexibility
- Higher costs at scale
- Vendor lock-in
- Harder to implement complex analytics

**Good for:** Early stage, MVP validation

### 6. **SQLite/Hive** (Local Mobile Cache)
**Why:**
- Offline-first capability
- Fast local queries
- Reduced API calls
- Better UX

**What to cache:**
```
- User profile
- Recent referrals
- Transaction history
- Program list
- Leaderboard (top 100)
```

## Recommended Architecture

### **Option A: Production-Grade (Recommended)**
```
PostgreSQL (Primary)
├── Relational data
├── Financial transactions
├── Audit logs
└── User management

Redis (Cache Layer)
├── Sessions
├── Real-time leaderboard
├── OTP/verification
└── Rate limiting

Elasticsearch (Analytics)
├── Referral search
├── User analytics
├── Activity timeline
└── Fraud detection

S3/Cloud Storage
└── User avatars, documents

Message Queue (RabbitMQ/Kafka)
├── Email notifications
├── SMS notifications
├── Withdrawal processing
└── Analytics events
```

### **Option B: Startup-Friendly (Balanced)**
```
PostgreSQL (Primary)
├── All relational data
├── Financial transactions
└── Audit logs

Redis (Cache)
├── Sessions
├── Real-time updates
└── Rate limiting

Firebase Storage
└── File uploads

Scheduled Jobs (Cron)
├── Leaderboard updates
├── Notification batching
└── Analytics aggregation
```

### **Option C: MVP (Quick Start)**
```
Firebase/Firestore
├── All data
├── Real-time updates
└── Built-in auth

Firebase Storage
└── File uploads

Firebase Functions
└── Backend logic
```

## Comparison Table

| Feature | PostgreSQL | MongoDB | Firebase | DynamoDB |
|---------|-----------|---------|----------|----------|
| ACID | ✅ | ❌ | ⚠️ | ❌ |
| Relational | ✅ | ❌ | ❌ | ❌ |
| Scalability | ⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ | ⭐⭐⭐⭐⭐ |
| Cost (Scale) | $ | $$ | $$$ | $$ |
| Learning Curve | ⭐⭐ | ⭐⭐⭐ | ⭐ | ⭐⭐⭐ |
| Analytics | ✅ | ⚠️ | ❌ | ❌ |

## My Recommendation

**For a modern referring app, use:**

1. **PostgreSQL** - Primary database (financial integrity)
2. **Redis** - Caching & real-time features
3. **Elasticsearch** - Analytics & search
4. **SQLite/Hive** - Mobile offline cache
5. **S3** - File storage

This gives you:
- ✅ Financial security (ACID)
- ✅ Scalability (Redis + Elasticsearch)
- ✅ Real-time features (Redis Pub/Sub)
- ✅ Analytics capabilities (Elasticsearch)
- ✅ Offline support (SQLite)
- ✅ Cost efficiency (PostgreSQL is cheaper than Firebase at scale)

