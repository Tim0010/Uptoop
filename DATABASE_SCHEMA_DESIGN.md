# PostgreSQL Schema Design for Modern Referring App

## Core Tables

### 1. Users Table
```sql
CREATE TABLE users (
  id UUID PRIMARY KEY,
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20) UNIQUE NOT NULL,
  name VARCHAR(255) NOT NULL,
  password_hash VARCHAR(255) NOT NULL,
  referral_code VARCHAR(20) UNIQUE NOT NULL,
  
  -- Profile
  avatar_url TEXT,
  age INT,
  school VARCHAR(255),
  interests TEXT[], -- Array of interests
  
  -- Gamification
  level INT DEFAULT 1,
  total_earnings DECIMAL(10,2) DEFAULT 0,
  pending_earnings DECIMAL(10,2) DEFAULT 0,
  monthly_earnings DECIMAL(10,2) DEFAULT 0,
  total_referrals INT DEFAULT 0,
  active_referrals INT DEFAULT 0,
  current_streak INT DEFAULT 0,
  coins INT DEFAULT 0,
  
  -- Verification
  email_verified BOOLEAN DEFAULT FALSE,
  phone_verified BOOLEAN DEFAULT FALSE,
  kyc_status VARCHAR(50) DEFAULT 'pending', -- pending, approved, rejected
  kyc_document_url TEXT,
  
  -- Metadata
  device_id VARCHAR(255),
  platform VARCHAR(50), -- ios, android, web
  last_login_at TIMESTAMP,
  last_ip_address INET,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  deleted_at TIMESTAMP -- Soft delete
);

CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_referral_code ON users(referral_code);
CREATE INDEX idx_users_created_at ON users(created_at);
```

### 2. Referrals Table
```sql
CREATE TABLE referrals (
  id UUID PRIMARY KEY,
  referrer_id UUID NOT NULL REFERENCES users(id),
  referee_id UUID REFERENCES users(id), -- NULL until they sign up
  
  friend_name VARCHAR(255) NOT NULL,
  friend_email VARCHAR(255) NOT NULL,
  friend_phone VARCHAR(20),
  
  program_id UUID NOT NULL REFERENCES programs(id),
  university_name VARCHAR(255) NOT NULL,
  
  status VARCHAR(50) DEFAULT 'invited', -- invited, clicked, registered, application_started, documents, fee_paid, enrolled, rejected
  earning DECIMAL(10,2) DEFAULT 0,
  
  -- Tracking
  referral_source VARCHAR(50), -- direct, social, email, qr, link
  conversion_funnel JSONB, -- {invited_at, clicked_at, registered_at, enrolled_at}
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW(),
  enrolled_at TIMESTAMP,
  expires_at TIMESTAMP -- Referral validity period
);

CREATE INDEX idx_referrals_referrer ON referrals(referrer_id);
CREATE INDEX idx_referrals_status ON referrals(status);
CREATE INDEX idx_referrals_created_at ON referrals(created_at);
```

### 3. Programs Table
```sql
CREATE TABLE programs (
  id UUID PRIMARY KEY,
  university_id UUID NOT NULL REFERENCES universities(id),
  name VARCHAR(255) NOT NULL,
  category VARCHAR(100),
  duration VARCHAR(50),
  mode VARCHAR(50), -- online, offline, hybrid
  earning DECIMAL(10,2) NOT NULL,
  
  logo_url TEXT,
  description TEXT,
  highlights TEXT[],
  
  is_active BOOLEAN DEFAULT TRUE,
  max_referrals INT,
  current_referrals INT DEFAULT 0,
  
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);
```

### 4. Transactions Table
```sql
CREATE TABLE transactions (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  
  type VARCHAR(50) NOT NULL, -- earning, withdrawal, bonus, penalty, refund
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, processing, completed, failed
  
  description TEXT,
  referral_id UUID REFERENCES referrals(id),
  
  payment_method VARCHAR(50), -- upi, bank, paytm, wallet
  transaction_id VARCHAR(255), -- External payment gateway ID
  
  created_at TIMESTAMP DEFAULT NOW(),
  completed_at TIMESTAMP,
  
  metadata JSONB -- Additional payment info
);

CREATE INDEX idx_transactions_user ON transactions(user_id);
CREATE INDEX idx_transactions_status ON transactions(status);
CREATE INDEX idx_transactions_created_at ON transactions(created_at);
```

### 5. Withdrawals Table
```sql
CREATE TABLE withdrawals (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  
  amount DECIMAL(10,2) NOT NULL,
  status VARCHAR(50) DEFAULT 'pending', -- pending, approved, processing, completed, failed, rejected
  
  payment_method VARCHAR(50) NOT NULL, -- upi, bank, paytm
  account_details JSONB NOT NULL, -- {upi_id, bank_account, ifsc, etc}
  
  requested_at TIMESTAMP DEFAULT NOW(),
  processed_at TIMESTAMP,
  
  failure_reason TEXT,
  transaction_id VARCHAR(255) -- Link to transaction
);

CREATE INDEX idx_withdrawals_user ON withdrawals(user_id);
CREATE INDEX idx_withdrawals_status ON withdrawals(status);
```

### 6. Achievements Table
```sql
CREATE TABLE achievements (
  id UUID PRIMARY KEY,
  name VARCHAR(255) NOT NULL,
  description TEXT,
  icon_url TEXT,
  
  criteria JSONB NOT NULL, -- {referrals_count, earnings_amount, streak_days}
  rarity VARCHAR(50), -- common, rare, epic, legendary
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE TABLE user_achievements (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  achievement_id UUID NOT NULL REFERENCES achievements(id),
  
  unlocked_at TIMESTAMP DEFAULT NOW(),
  
  UNIQUE(user_id, achievement_id)
);
```

### 7. Audit Logs Table
```sql
CREATE TABLE audit_logs (
  id UUID PRIMARY KEY,
  user_id UUID REFERENCES users(id),
  
  action VARCHAR(255) NOT NULL,
  entity_type VARCHAR(100), -- user, referral, transaction, withdrawal
  entity_id UUID,
  
  changes JSONB, -- {before, after}
  ip_address INET,
  user_agent TEXT,
  
  created_at TIMESTAMP DEFAULT NOW()
);

CREATE INDEX idx_audit_logs_user ON audit_logs(user_id);
CREATE INDEX idx_audit_logs_created_at ON audit_logs(created_at);
```

### 8. Notifications Table
```sql
CREATE TABLE notifications (
  id UUID PRIMARY KEY,
  user_id UUID NOT NULL REFERENCES users(id),
  
  type VARCHAR(50), -- referral_accepted, earning_credited, withdrawal_processed
  title VARCHAR(255) NOT NULL,
  body TEXT NOT NULL,
  
  action_url TEXT,
  is_read BOOLEAN DEFAULT FALSE,
  
  created_at TIMESTAMP DEFAULT NOW(),
  expires_at TIMESTAMP
);
```

## Key Design Decisions

1. **UUID for IDs** - Better for distributed systems
2. **JSONB for Metadata** - Flexible schema for future features
3. **Soft Deletes** - Preserve data for compliance
4. **Timestamps** - Track all changes
5. **Indexes** - Optimize common queries
6. **Foreign Keys** - Maintain referential integrity
7. **Enums** - Use VARCHAR with constraints for flexibility

## Relationships Diagram

```
users (1) ──→ (many) referrals
users (1) ──→ (many) transactions
users (1) ──→ (many) withdrawals
users (1) ──→ (many) achievements
users (1) ──→ (many) audit_logs
users (1) ──→ (many) notifications

referrals (many) ──→ (1) programs
programs (many) ──→ (1) universities

transactions (many) ──→ (1) referrals
```

## Performance Considerations

1. **Partitioning** - Partition transactions by date for large datasets
2. **Materialized Views** - Pre-calculate leaderboards
3. **Read Replicas** - For analytics queries
4. **Connection Pooling** - Use PgBouncer
5. **Query Optimization** - Regular EXPLAIN ANALYZE

