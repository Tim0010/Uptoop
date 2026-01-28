# API Design Patterns for Modern Referring App

## RESTful API Endpoints

### Authentication
```
POST   /api/v1/auth/register          - User registration
POST   /api/v1/auth/login             - User login
POST   /api/v1/auth/refresh-token     - Refresh JWT
POST   /api/v1/auth/logout            - Logout
POST   /api/v1/auth/verify-email      - Email verification
POST   /api/v1/auth/verify-phone      - Phone verification
POST   /api/v1/auth/forgot-password   - Password reset
```

### User Management
```
GET    /api/v1/users/me               - Get current user profile
PUT    /api/v1/users/me               - Update profile
GET    /api/v1/users/:id              - Get user public profile
POST   /api/v1/users/kyc              - Submit KYC documents
GET    /api/v1/users/me/stats         - Get user statistics
GET    /api/v1/users/me/achievements  - Get user achievements
```

### Referrals
```
GET    /api/v1/referrals              - List user's referrals (paginated)
POST   /api/v1/referrals              - Create new referral
GET    /api/v1/referrals/:id          - Get referral details
PUT    /api/v1/referrals/:id          - Update referral status
GET    /api/v1/referrals/analytics    - Referral analytics
POST   /api/v1/referrals/:id/resend   - Resend referral invite
```

### Programs
```
GET    /api/v1/programs               - List all programs (with filters)
GET    /api/v1/programs/:id           - Get program details
GET    /api/v1/programs/trending      - Get trending programs
GET    /api/v1/programs/search        - Search programs
```

### Wallet & Transactions
```
GET    /api/v1/wallet                 - Get wallet balance
GET    /api/v1/transactions           - List transactions (paginated)
GET    /api/v1/transactions/:id       - Get transaction details
POST   /api/v1/withdrawals            - Request withdrawal
GET    /api/v1/withdrawals            - List withdrawals
GET    /api/v1/withdrawals/:id        - Get withdrawal details
```

### Leaderboard
```
GET    /api/v1/leaderboard            - Get global leaderboard
GET    /api/v1/leaderboard/monthly    - Monthly leaderboard
GET    /api/v1/leaderboard/friends    - Friends leaderboard
GET    /api/v1/leaderboard/rank       - Get user's rank
```

### Notifications
```
GET    /api/v1/notifications          - List notifications
PUT    /api/v1/notifications/:id/read - Mark as read
DELETE /api/v1/notifications/:id      - Delete notification
POST   /api/v1/notifications/settings - Update notification preferences
```

## Request/Response Format

### Standard Response
```json
{
  "success": true,
  "data": { /* response data */ },
  "message": "Operation successful",
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Error Response
```json
{
  "success": false,
  "error": {
    "code": "INVALID_EMAIL",
    "message": "Email format is invalid",
    "details": { /* additional info */ }
  },
  "timestamp": "2024-01-15T10:30:00Z"
}
```

### Paginated Response
```json
{
  "success": true,
  "data": [ /* items */ ],
  "pagination": {
    "page": 1,
    "limit": 20,
    "total": 150,
    "pages": 8
  }
}
```

## Data Flow Examples

### Referral Creation Flow
```
1. User clicks "Refer Friend"
2. App sends: POST /api/v1/referrals
   {
     "friendEmail": "friend@example.com",
     "friendPhone": "+91...",
     "programId": "uuid",
     "source": "direct"
   }

3. Backend:
   - Creates referral record (status: invited)
   - Stores in PostgreSQL
   - Caches in Redis
   - Publishes to Elasticsearch
   - Queues email notification

4. Response:
   {
     "id": "referral_uuid",
     "status": "invited",
     "referralLink": "https://app.com/ref/ABC123",
     "expiresAt": "2024-02-15T10:30:00Z"
   }

5. Backend sends email via RabbitMQ → SendGrid
```

### Withdrawal Flow
```
1. User requests withdrawal
2. App sends: POST /api/v1/withdrawals
   {
     "amount": 500,
     "paymentMethod": "upi",
     "accountDetails": { "upiId": "user@upi" }
   }

3. Backend:
   - Validates balance
   - Creates withdrawal record (status: pending)
   - Stores in PostgreSQL
   - Queues for processing

4. Async Worker:
   - Calls payment gateway (Razorpay)
   - Updates withdrawal status
   - Creates transaction record
   - Sends SMS notification

5. User receives SMS with status
```

### Real-time Leaderboard Update
```
1. User completes referral
2. Backend:
   - Updates user earnings in PostgreSQL
   - Increments Redis leaderboard score
   - Publishes WebSocket event

3. All connected clients receive:
   {
     "type": "leaderboard_update",
     "userId": "user_uuid",
     "newRank": 5,
     "earnings": 5000
   }

4. App updates UI in real-time
```

## Caching Strategy

### Cache Layers
```
L1: Browser/App Cache (SQLite/Hive)
    - User profile
    - Recent referrals
    - Transaction history
    - TTL: 1 hour

L2: Redis Cache
    - User sessions
    - Leaderboard (top 100)
    - Program list
    - OTP/verification codes
    - TTL: 5 min - 24 hours

L3: Database (PostgreSQL)
    - Source of truth
    - Persistent storage
```

### Cache Invalidation
```
- User profile update → Invalidate user:{userId}
- New referral → Invalidate leaderboard
- Withdrawal processed → Invalidate wallet:{userId}
- Program updated → Invalidate programs:*
```

## Rate Limiting

```
- API calls: 100 requests/minute per user
- Referral creation: 10 per hour
- Withdrawal requests: 5 per day
- Login attempts: 5 per 15 minutes

Implement via Redis:
  rate_limit:{userId}:{endpoint} → Counter with TTL
```

## Security Headers

```
Authorization: Bearer {JWT_TOKEN}
X-Request-ID: {unique_id}
X-API-Version: v1
Content-Type: application/json
```

## Error Codes

```
400 - Bad Request
401 - Unauthorized
403 - Forbidden
404 - Not Found
409 - Conflict (duplicate referral)
422 - Unprocessable Entity (validation error)
429 - Too Many Requests (rate limit)
500 - Internal Server Error
503 - Service Unavailable
```

## Versioning Strategy

- Use URL versioning: `/api/v1/`, `/api/v2/`
- Maintain backward compatibility for 2 versions
- Deprecate old versions with 6-month notice
- Use Accept header for content negotiation

