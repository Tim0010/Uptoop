# Supabase Implementation Guide for Referring App

## Why Supabase for Your App?

✅ **PostgreSQL Foundation** - ACID compliance for financial transactions
✅ **Real-time Capabilities** - Live leaderboard updates
✅ **Built-in Auth** - User management out of the box
✅ **Affordable** - $100-500/month at 100K users
✅ **Easy Migration** - Can migrate to self-hosted PostgreSQL later
✅ **No Vendor Lock-in** - Open source, can self-host

## Getting Started with Supabase

### Step 1: Create Supabase Project

```bash
# Go to https://supabase.com
# Sign up with GitHub
# Create new project
# Choose region (closest to your users)
# Wait for project to initialize (~2 minutes)
```

### Step 2: Get Connection Details

```
Project URL: https://[project-id].supabase.co
API Key: (anon key for frontend)
Service Role Key: (secret key for backend)
Database URL: postgresql://[user]:[password]@[host]:5432/postgres
```

### Step 3: Create Tables

Use Supabase SQL Editor to create tables:

```sql
-- Users table
CREATE TABLE users (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  email VARCHAR(255) UNIQUE NOT NULL,
  phone VARCHAR(20),
  referral_code VARCHAR(20) UNIQUE NOT NULL,
  total_earnings DECIMAL(10, 2) DEFAULT 0,
  pending_earnings DECIMAL(10, 2) DEFAULT 0,
  level INT DEFAULT 1,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Referrals table
CREATE TABLE referrals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  referrer_id UUID REFERENCES users(id),
  referee_email VARCHAR(255),
  program_id UUID,
  status VARCHAR(50) DEFAULT 'invited',
  earning DECIMAL(10, 2) DEFAULT 0,
  created_at TIMESTAMP DEFAULT NOW(),
  updated_at TIMESTAMP DEFAULT NOW()
);

-- Transactions table
CREATE TABLE transactions (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  type VARCHAR(50),
  amount DECIMAL(10, 2),
  status VARCHAR(50) DEFAULT 'pending',
  created_at TIMESTAMP DEFAULT NOW()
);

-- Withdrawals table
CREATE TABLE withdrawals (
  id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
  user_id UUID REFERENCES users(id),
  amount DECIMAL(10, 2),
  status VARCHAR(50) DEFAULT 'pending',
  payment_method VARCHAR(50),
  created_at TIMESTAMP DEFAULT NOW()
);
```

## Flutter Integration

### Step 1: Add Dependencies

```yaml
dependencies:
  supabase_flutter: ^1.10.0
  shared_preferences: ^2.0.0
```

### Step 2: Initialize Supabase

```dart
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await Supabase.initialize(
    url: 'https://[project-id].supabase.co',
    anonKey: '[anon-key]',
  );
  
  runApp(const MyApp());
}
```

### Step 3: Create Supabase Service

```dart
class SupabaseService {
  final supabase = Supabase.instance.client;
  
  // Authentication
  Future<AuthResponse> signUp(String email, String password) async {
    return await supabase.auth.signUp(
      email: email,
      password: password,
    );
  }
  
  Future<AuthResponse> signIn(String email, String password) async {
    return await supabase.auth.signInWithPassword(
      email: email,
      password: password,
    );
  }
  
  // User operations
  Future<Map<String, dynamic>> getUser(String userId) async {
    return await supabase
        .from('users')
        .select()
        .eq('id', userId)
        .single();
  }
  
  Future<void> updateUser(String userId, Map<String, dynamic> data) async {
    await supabase
        .from('users')
        .update(data)
        .eq('id', userId);
  }
  
  // Referral operations
  Future<List<Map<String, dynamic>>> getReferrals(String userId) async {
    return await supabase
        .from('referrals')
        .select()
        .eq('referrer_id', userId);
  }
  
  Future<void> createReferral(Map<String, dynamic> data) async {
    await supabase.from('referrals').insert(data);
  }
  
  // Real-time subscriptions
  void subscribeToLeaderboard(Function(List) onUpdate) {
    supabase
        .from('users')
        .on(RealtimeListenOptions(
          event: RealtimeListenTypes.all,
          schema: 'public',
        ), (payload) {
          onUpdate(payload);
        })
        .subscribe();
  }
}
```

### Step 4: Use in Provider

```dart
class UserProvider extends ChangeNotifier {
  final supabaseService = SupabaseService();
  
  Future<void> login(String email, String password) async {
    try {
      await supabaseService.signIn(email, password);
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
  
  Future<void> loadUser(String userId) async {
    try {
      final user = await supabaseService.getUser(userId);
      // Update state
      notifyListeners();
    } catch (e) {
      rethrow;
    }
  }
}
```

## Backend Integration (Node.js Example)

### Step 1: Install Supabase Client

```bash
npm install @supabase/supabase-js
```

### Step 2: Create Supabase Client

```javascript
import { createClient } from '@supabase/supabase-js'

const supabase = createClient(
  'https://[project-id].supabase.co',
  '[service-role-key]'
)

export default supabase
```

### Step 3: API Endpoints

```javascript
// Create referral
app.post('/api/referrals', async (req, res) => {
  const { referrerId, refereeEmail, programId } = req.body
  
  const { data, error } = await supabase
    .from('referrals')
    .insert([{
      referrer_id: referrerId,
      referee_email: refereeEmail,
      program_id: programId,
      status: 'invited'
    }])
  
  if (error) return res.status(400).json(error)
  res.json(data)
})

// Get leaderboard
app.get('/api/leaderboard', async (req, res) => {
  const { data, error } = await supabase
    .from('users')
    .select('id, email, total_earnings, level')
    .order('total_earnings', { ascending: false })
    .limit(100)
  
  if (error) return res.status(400).json(error)
  res.json(data)
})

// Process withdrawal
app.post('/api/withdrawals', async (req, res) => {
  const { userId, amount, paymentMethod } = req.body
  
  // Start transaction
  const { data: user } = await supabase
    .from('users')
    .select('pending_earnings')
    .eq('id', userId)
    .single()
  
  if (user.pending_earnings < amount) {
    return res.status(400).json({ error: 'Insufficient balance' })
  }
  
  // Create withdrawal
  const { data: withdrawal } = await supabase
    .from('withdrawals')
    .insert([{
      user_id: userId,
      amount,
      payment_method: paymentMethod,
      status: 'pending'
    }])
  
  // Update user earnings
  await supabase
    .from('users')
    .update({ pending_earnings: user.pending_earnings - amount })
    .eq('id', userId)
  
  res.json(withdrawal)
})
```

## Real-time Features

### Leaderboard Updates

```dart
class LeaderboardProvider extends ChangeNotifier {
  final supabase = Supabase.instance.client;
  List<User> leaderboard = [];
  
  void subscribeToLeaderboard() {
    supabase
        .from('users')
        .on(RealtimeListenOptions(
          event: RealtimeListenTypes.all,
          schema: 'public',
        ), (payload) {
          _updateLeaderboard();
        })
        .subscribe();
  }
  
  Future<void> _updateLeaderboard() async {
    final data = await supabase
        .from('users')
        .select()
        .order('total_earnings', { ascending: false })
        .limit(100);
    
    leaderboard = data.map((u) => User.fromJson(u)).toList();
    notifyListeners();
  }
}
```

### Referral Status Updates

```dart
void subscribeToReferralUpdates(String userId) {
  supabase
      .from('referrals')
      .on(RealtimeListenOptions(
        event: RealtimeListenTypes.all,
        schema: 'public',
        filter: PostgresChangeFilter(
          type: PostgresChangeFilterType.eq,
          column: 'referrer_id',
          value: userId,
        ),
      ), (payload) {
        // Update referral status in real-time
        notifyListeners();
      })
      .subscribe();
}
```

## Security with Row-Level Security (RLS)

```sql
-- Enable RLS
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE referrals ENABLE ROW LEVEL SECURITY;

-- Users can only see their own data
CREATE POLICY "Users can view own data"
  ON users FOR SELECT
  USING (auth.uid() = id);

-- Users can only update their own data
CREATE POLICY "Users can update own data"
  ON users FOR UPDATE
  USING (auth.uid() = id);

-- Users can only see their own referrals
CREATE POLICY "Users can view own referrals"
  ON referrals FOR SELECT
  USING (auth.uid() = referrer_id);
```

## Deployment

### Option 1: Supabase Hosting (Recommended for MVP)

```bash
# Use Supabase dashboard
# No deployment needed
# Automatic backups
# Automatic scaling
```

### Option 2: Self-hosted PostgreSQL (Later)

```bash
# Export data from Supabase
# Set up PostgreSQL server
# Import data
# Update connection strings
# Done!
```

## Cost Breakdown

| Plan | Price | Users | Includes |
|------|-------|-------|----------|
| Free | $0 | 1K | 500MB storage |
| Pro | $25 | 10K | 8GB storage |
| Business | $100 | 100K | 100GB storage |
| Enterprise | Custom | 1M+ | Custom |

## Migration to PostgreSQL (Later)

```bash
# Step 1: Export from Supabase
pg_dump -h [host] -U [user] -d postgres > backup.sql

# Step 2: Import to PostgreSQL
psql -h [new-host] -U [user] -d postgres < backup.sql

# Step 3: Update connection strings
# Update .env files
# Update Flutter app
# Update backend

# Step 4: Test thoroughly
# Run all tests
# Verify data integrity
# Monitor performance
```

## Conclusion

**Supabase is the perfect choice for your referring app because:**

✅ PostgreSQL foundation (ACID safe)
✅ Real-time capabilities
✅ Built-in authentication
✅ Affordable pricing
✅ Easy to migrate later
✅ No vendor lock-in

**Start with Supabase, migrate to self-hosted PostgreSQL when you need more control!**

